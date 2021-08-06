classdef classFZ  < handle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        Ts;
        Tf;
        
        
        S=16.1651;
        m=1043.3;
        Cw0=0.031;
        k=0.06;
        dCadalpha=4.93;
        Pmax=120*1000;
        
        Cm0=-0.015;
        Cmalpha=-0.89;
        Cmq=-12.4;
        Cme=-1.28;
        
        c=5;
        V0=62.7;
        q_bar=0.5*1.225*3931;
        Iy=1824.9;
        PropEff=0.7;
        
        
        xd=0;%x_dot
        xd0;
        xdd=0;%x_doubledot
        
        
        gamma;%Bahnneigungswinkel
        gamma0;
        gammad;%gamma_dot
        
        
        alpha;%Angle of Attack
        alpha0;
        alphad;
        
        q;%Drehgeschwindigkeit
        q0;
        qd;
        
        
        X;%X_coord.
        Y;
        
        XG;%the location of goal(Maximal)
        YG;
        
        XO;%the location of Obstacle
        YO;
        RO;%the Radius of Obstacle
        t;
        
        X0;%The start location(Max)
        Y0;
        
        
        U;%Speed in X_coord
        V;
        
      
        Xmax;
        Ymax;
        
        delta;
        delta0;
        KL;
        KL0;
        HR;
        HR0;
        
        Distance;
      
    end
    %=================================================%
    properties (Access = private)
        hVec;
        hPlot;
        hScatter;
        hText;
        hObs;
        g = 9.8;
        rho=1.225;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    methods
        
        %==================================================%
        % initializing the class (constructor)
        
        function obj = classFZ(Ts,Tf,X0,xd0,gamma0,q0,alpha0,RO,Xmax,Ymax)%The parameters witch you want to set up at start of simulation
            obj.Ts = Ts;
            obj.Tf = Tf;
            
            obj.X0 = X0*rand;
            obj.Y0 = Ymax*(0.25+0.5*rand);
            
            
            obj.X = X0;
            obj.X0 = X0;
            obj.xd = xd0;
            obj.xd0 = xd0;

            obj.Y = Ymax*(0.25+0.5*rand);
            
            obj.XG = Xmax*0.9;
            obj.YG = Ymax*(0.25+0.5*rand);
            
            obj.XO = Xmax*0.9/2;
            obj.YO = Ymax*(0.25+0.5*rand);
            obj.RO = RO;
            obj.t = linspace(0,2*pi,100);
            
            obj.gamma = gamma0;
            obj.gamma0 = gamma0;
            
            obj.alpha = alpha0;
            obj.alpha0 = alpha0;
            obj.alphad = 0;
            
            obj.q = q0;
            obj.q0 = q0;
            obj.qd = 0;
            
            obj.delta0= 0.5;
            obj.HR0=0;
            obj.KL0=0;
            
            obj.delta = 0.5;
            obj.KL = 0;
            obj.HR = 0;
            

            %size of the graph as output
            obj.Xmax = Xmax;
            obj.Ymax = Ymax;
            
            
            % creating figure
            h = figure('visible','off');
            
            obj.U = obj.xd*cos(obj.gamma);
            obj.V = obj.xd*sin(obj.gamma);
            scale=2;%scale of the arrow
            obj.hVec = quiver(obj.X, obj.Y, obj.U, obj.V,scale,'k','LineWidth', 4 ,'MaxHeadSize',10); %creating arrow
            obj.hText = text(0.5,200,'0','FontSize',14);%showing explanation　text(x,y,txt) 
            hold on
            obj.hScatter = scatter(obj.XG,obj.YG,'or','filled','SizeData',50);
           
            
            %draw the Obstacle
            obj.hObs = patch(obj.RO*sin(obj.t)+obj.XO,obj.RO*cos(obj.t)+obj.YO,'g');
            
            axis([0 obj.Xmax 0 obj.Ymax]);%size of the graph
        end
        
       %========================================================%
        
        %updating the discrete model with ONE time step
        %Parameters witch belong to the properties but not mentioned in the
        %constructors can be used with obj.** (* will be replaced)
        
        
        function FZstep(obj,delta,KL,HR)%delta and Ca are the input, no need of use of obj
            obj.delta = delta;
            obj.KL = KL;
            obj.HR = HR;
            
            F=obj.Pmax*obj.PropEff/obj.xd*(obj.delta0+(1-obj.delta0)*delta);
            Ca=(KL+1)*obj.dCadalpha*obj.alpha;
            
            obj.xdd = 1/obj.m*(-1/2*obj.rho*obj.S*obj.xd^2*(obj.Cw0+obj.k*Ca^2)...
                    +F*cos(obj.alpha)...
                    -obj.m*obj.g*sin(obj.gamma));
                
            obj.xd = obj.xd+obj.xdd*obj.Ts;
            
            obj.X=obj.X+obj.xd*cos(obj.gamma)*obj.Ts;
            obj.Y=obj.Y+obj.xd*sin(obj.gamma)*obj.Ts;
            
            
            obj.gammad = 1/(obj.m*obj.xd)*((1/2*obj.rho*obj.S*obj.xd^2*Ca^2)...
                          +F*sin(obj.alpha)...
                          -obj.m*obj.g*cos(obj.gamma));
                      
            obj.gamma = obj.gamma+obj.gammad*obj.Ts;
            
            obj.qd = obj.q_bar*obj.S/obj.Iy*(obj.c/obj.V0   *2*obj.Cm0*obj.xd...
                                            +obj.c          *obj.Cmalpha*obj.alpha...
                                            +obj.c/obj.V0   *obj.Cmq*obj.q...
                                            +obj.c          *obj.Cme*HR);
                                        
            %obj.qd = 1/obj.Iy*(obj.Cme * HR-9.4*obj.q-0.3*obj.alpha)
            %obj.qd = -1/5000*(obj.Cme * HR-9.4*obj.q-0.3*obj.alpha)
            %obj.qd = 1/100*(-100) %minus => nach unten
            
            obj.q = obj.q + obj.qd*obj.Ts;
            
            obj.alphad = obj.q - obj.gammad;
            obj.alpha = obj.alpha + obj.alphad*obj.Ts;
            
            obj.Distance = norm([obj.X, obj.Y]-[obj.XG, obj.YG]);

            
            %%%%%%%% Updating figure
            
            obj.hVec.XData = obj.X;%*Data is a property of quiver fct. corresponding to each parameter
            obj.hVec.YData = obj.Y;
            obj.hVec.UData = obj.xd*cos(obj.gamma);
            obj.hVec.VData = obj.xd*sin(obj.gamma);
            obj.hText.String = "delta: " + num2str(delta) + newline + ...
                               "KLAusschlag: " + num2str(KL) + newline + ...
                               "HRAusschlag: "+ num2str(HR) + newline + ...
                               "Gesch.: " + num2str(obj.xd);
            
            obj.hScatter.XData = obj.XG;
            obj.hScatter.YData = obj.YG;
            
            obj.hObs.XData = obj.RO*sin(obj.t)+obj.XO;
            obj.hObs.YData = obj.RO*cos(obj.t)+obj.YO;            
            
            
            drawnow
        end
        
        %==========================================================%
        
        function FZreset(obj)
        
            obj.X = obj.X0;
            obj.xd = obj.xd0;

            obj.Y = obj.Ymax*(0.25+0.5*rand);
            
            obj.YG = obj.Ymax*(0.25+0.5*rand);
            
            obj.YO = obj.Ymax*(0.25+0.5*rand);
            
            obj.gamma = obj.gamma0;
            obj.q = obj.q0;
            obj.alpha = obj.alpha0;
            
            obj.delta=obj.delta0;
            obj.KL=obj.KL0;
            obj.HR=obj.HR0;
            
           
            
        end
        
    end 
end