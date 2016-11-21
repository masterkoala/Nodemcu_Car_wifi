     --GPIO Pinleri Deklerasyon
     function initGPIO()
     --1,2EN     D1 GPIO5
     --3,4EN     D2 GPIO4
     --1A  ~2A   D3 GPIO0
     --3A  ~4A   D4 GPIO2

     gpio.mode(0,gpio.OUTPUT);--LED Isik Acik
     gpio.write(0,gpio.LOW);

     gpio.mode(1,gpio.OUTPUT);gpio.write(1,gpio.LOW);
     gpio.mode(2,gpio.OUTPUT);gpio.write(2,gpio.LOW);

     gpio.mode(3,gpio.OUTPUT);gpio.write(3,gpio.HIGH);
     gpio.mode(4,gpio.OUTPUT);gpio.write(4,gpio.HIGH);

     pwm.setup(1,1000,1023); --PWM 1KHz frekans, Hedef 1023
     pwm.start(1);pwm.setduty(1,0);
     pwm.setup(2,1000,1023);
     pwm.start(2);pwm.setduty(2,0);
     end

     function setupAPMode()
     print("Uygulama Modunda Calismaya Hazir")

     cfg={}
     cfg.ssid="Solar_Wifi_CAR"; --Wifi Adi Belirleme
     cfg.pwd="solar12345" --Wifi Sifre Belirleme
     wifi.ap.config(cfg)

     cfg={}
     cfg.ip="192.168.1.1"; -- onfigurasyon IP Adresi
     cfg.netmask="255.255.255.0"; -- Alt Ag Maskesi
     cfg.gateway="192.168.1.1"; --Ag gecidi
     wifi.ap.setip(cfg);
     wifi.setmode(wifi.SOFTAP)

     str=nil;
     ssidTemp=nil;
     collectgarbage();

     print("Uygulama Modu Basladi")
     end

     --Uygulama modu kurulumu
     setupAPMode();

     print("Solar Wifi Car Kontrolu Basladi");
     initGPIO();

     spdTargetA=1023;--hedef hiz
     spdCurrentA=0;--simdiki hiz
     spdTargetB=1023;--hedef hiz
     spdCurrentB=0;--simdiki hiz
     stopFlag=true;

     --Hiz Kontrol Proseduru
     tmr.alarm(1, 200, 1, function()
         if stopFlag==false then
             spdCurrentA=spdTargetA;
             spdCurrentB=spdTargetB;
             pwm.setduty(1,spdCurrentA);
             pwm.setduty(2,spdCurrentB);
         else
             pwm.setduty(1,0);
             pwm.setduty(2,0);
         end
     end)

     --9003 Portunda TCP Sunucu Acilimi
     s=net.createServer(net.TCP,60);
     s:listen(9003,function(c)
         c:on("receive",function(c,d)
           print("TCPSrv:"..d)
           if string.sub(d,1,1)=="0" then --DUR
             pwm.setduty(1,0)
             pwm.setduty(2,0)
             stopFlag = true;
             c:send("ok\r\n");
           elseif string.sub(d,1,1)=="1" then --ILERI
             gpio.write(3,gpio.HIGH)
             gpio.write(4,gpio.HIGH)
             stopFlag = false;
             c:send("ok\r\n");
           elseif string.sub(d,1,1)=="2" then --GERI
             gpio.write(3,gpio.LOW)
             gpio.write(4,gpio.LOW)
             stopFlag = false;
             c:send("ok\r\n");
           elseif string.sub(d,1,1)=="3" then --SOL
             gpio.write(3,gpio.LOW)
             gpio.write(4,gpio.HIGH)
             stopFlag = false;
             c:send("ok\r\n");
           elseif string.sub(d,1,1)=="4" then --SAG
             gpio.write(3,gpio.HIGH);
             gpio.write(4,gpio.LOW);
             stopFlag = false;
             c:send("ok\r\n");
           elseif string.sub(d,1,1)=="6" then --SAG MOTORLAR HIZLAN (A)
             spdTargetA = spdTargetA+50;if(spdTargetA>1023) then spdTargetA=1023;end
             c:send("ok\r\n");
           elseif string.sub(d,1,1)=="7" then --SAG MOTORLAR YAVASLA (A)
             spdTargetA = spdTargetA-50;if(spdTargetA<0) then spdTargetA=0;end
             c:send("ok\r\n");
           elseif string.sub(d,1,1)=="8" then --SOL MOTORLAR HIZLAN (B)
             spdTargetB = spdTargetB+50;if(spdTargetB>1023) then spdTargetB=1023;end
             c:send("ok\r\n");
           elseif string.sub(d,1,1)=="9" then --SOL MOTORLAR YAVASLA (B)
             spdTargetB = spdTargetB-50;if(spdTargetB<0) then spdTargetB=0;end
             c:send("ok\r\n");
           else  print("Yanlis Komut:"..d);c:send("Invalid CMD\r\n");end;
           collectgarbage();
         end) --son c:on komutu yakalama

         c:on("disconnection",function(c)
             print("TCPSrv:Kullanici Koptu");
             collectgarbage();
         end)
         print("TCPSrv:Kullanici Baglandi")
     end)
