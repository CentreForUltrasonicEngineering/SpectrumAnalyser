%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                   %
%   Copyright (C) 2016 University of Strathclyde    %
%                                                   %
%   Author: Timothy Lardner                         %
%   Email:  timothy.lardner@strath.ac.uk            %
%                                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef HP_Spec < handle
    
    properties
        comm_obj;
        last_frame;
        freq_range;
    end
    
    methods
        function self = HP_Spec(varargin)
            if nargin==2
                BoardAd = varargin{0};
                PrimAd = varargin{1};
            elseif nargin==0
                BoardAd = 0;
                PrimAd = 18;
            else
                error('Unexpected number of arguments');
            end
            obj1 = instrfind('Type', 'gpib', 'BoardIndex', BoardAd, 'PrimaryAddress', PrimAd, 'Tag', '');
            if isempty(obj1)
                obj1 = gpib('NI', BoardAd, PrimAd);
            else
                fclose(obj1);
                obj1 = obj1(1);
            end
            self.comm_obj = obj1;
            fopen(self.comm_obj);
            self.comm_obj.EOSMode = 'read&write';
            self.comm_obj.EOSCharCode = 'LF';
        end
        
        function initialise(self,freq_range)
            self.freq_range = freq_range;
            fprintf(self.comm_obj,'TDF B;'); 
            fprintf(self.comm_obj,'IP;SNGLS;');
            fprintf(self.comm_obj,'CF %G;',freq_range);
            fprintf(self.comm_obj,'SP %G;',freq_range*2);   
        end
        
        function output = getFrame(self)
            formatSpec = '%c';
            fprintf(self.comm_obj,'TS;');
            fprintf(self.comm_obj,'TRA?;');
            combined = [];
            while true
                data = fscanf(self.comm_obj,formatSpec);
                if isempty(data) || strcmp(data(end),char(10))
                    break
                else
                    combined = [combined data];
                end
            end
            output = self.fix_data(combined);
            self.last_frame = output;
        end
        
        function close(self)
            fclose(self.comm_obj);
            self.comm_obj = [];
        end
        
        function output = fix_data(~,data)
            split = strsplit(data,',');
            output = str2double(split);
        end
       
        
        function plotLastFrame(self)
            x_axis = get_x_axis(self);
            figure(7656); clf;
            plot(x_axis,self.last_frame);  ylim([-80 0]); 
            ylabel('Amplitude (dB)'); xlabel('Freqency (Hz)');
            drawnow;
        end
        
        function x_axis = get_x_axis(self)
            x_axis = linspace(0,self.freq_range,length(self.last_frame));
        end
        
    end
    
end

