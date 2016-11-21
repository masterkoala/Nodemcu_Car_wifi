 print("\n")
 print("ESP8266 NodeMCU Solar_Wifi_Car v0.1 Basladi")
 print("Zeynel Dogus OZEL")
 print("Dokuz Eylul Universitesi Fizik Bolumu")
 print("2016 Bitirme Projesi")
 print("Yrd.Dc.Dr. Kadir AKGUNGOR")
 print("Wifi SSID = Solar_Wifi_CAR")
 print("Wifi Sifre = solar12345")
 local exefile="dogusSolarWifiCar" -- compile baslatici
 local luaFile = {exefile..".lua"} -- Lua dosyasi calistirilir
 for i, f in ipairs(luaFile) do
 if file.open(f) then
 file.close()
 print("Derlenen Dosya:"..f)
 node.compile(f) -- derleme komutu *.lua dosyasini *.lc haline getirir
 print("Kaldirilan Dosya:"..f)
 file.remove(f) -- kullanilmicak dosya kaldirilir
 end
 end
if file.open(exefile..".lc") then --*.lc dosyasi acilir
 dofile(exefile..".lc") -- *.lc dosyasi calistirilir
 else
 print(exefile..".lc not exist") -- *.lc dosyasi yoksa hata ekrani
 end
 exefile=nil;luaFile = nil
 collectgarbage()
