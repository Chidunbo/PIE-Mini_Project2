clear
% serial port setup
port = "COM14";
s = serialport(port,9600);
configureTerminator(s,"CR/LF");
% create serial port object with four fields: distance, x, y and data count
s.UserData = struct("distance",[],"x",[],"y",[],"Count",1); 

% initialization
run = 1;
i = 1;
sensor_read_list = [];
coefs = [9800,-0.9614]; % best-fit curve coefficients


while run == 1
    % calibrating phase: both servos at 90 degrees
    if i == 1
    % reading serial data line
    line = readline(s);
    % converting sensor readings to double type distance values
    sensor_read_origin = str2double(line);
    % calculate distance using best-fit function
    distance_origin = coefs(1)*sensor_read_origin ^ coefs(2);
    % set distance tolerance
    buffer = 0.2 * sensor_read_origin;
    % record x,y,distance at orgin
    s.UserData.distance(end+1)= distance_origin;
    s.UserData.x(end+1)= 0;
    s.UserData.y(end+1)= 0;
    i = i + 1;
    
    end
    
    % sweeping phase: read distance left to right, top to bottom
    if i > 1
        % reading serial data line
        line = readline(s);
        % converting sensor readings to double type distance values
        separate_line = regexp(line, '/', 'split');
        double_line = str2double(separate_line);
        bottom_angle = double_line(1);
        top_angle = double_line(2);
        sensor_read  = double_line(3);
        
        % determine if reading is valid
        % if yes, set it to origin distance
        % if no, discard the data
        if sensor_read >= sensor_read_origin - buffer
            sensor_read_list(end+1) = distance_origin;
        else
            sensor_read_list(end+1) = NaN;
        end 
        
        % calculate distance using best-fit function and save it
        distance_x = coefs(1)*sensor_read_list(end) ^ coefs(2);
        s.UserData.distance(end+1)= distance_x;
        s.UserData.x(end+1)= distance_origin * tand(bottom_angle);
        s.UserData.y(end+1)= distance_origin * tand(top_angle);
        
        % Update the Count value of the serialport object.
        s.UserData.Count = s.UserData.Count + 1;
        
        % If 5 data points have been collected from the Arduino, switch off the
        % callbacks and plot the data.
        if s.UserData.Count > 5
            configureCallback(s, "off");
            % 3D plotting valid data points, if data invalid, move on to
            % the next point
            try
                plot3(s.UserData.x(2:end),s.UserData.distance(2:end),s.UserData.y(2:end),'.r', 'MarkerSize',30)
                zlabel("y(cm)")
                xlabel("x(cm)")
                ylabel("distance(cm)")
            catch
                continue
            end 
        end
    end 
end