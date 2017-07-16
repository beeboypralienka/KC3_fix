        %------------------------------------
        % Cari anggota baru hingga konvergen
        %------------------------------------
        konvergen = true;
        while konvergen          
        %--                               
            %-----------------------------------------
            % Hitung MEAN per fitur anggota C1 "temp"
            %-----------------------------------------
            KC3_29_Mean_C1_Temp{1,iFitur}{iFold,1}(1,:) = mean(KC3_26_Anggota_C1_Temp{1,iFitur}{iFold,1}(:,1:iFitur));                 
   
            %-----------------------------------------
            % Hitung MEAN per fitur anggota C2 "temp"
            %-----------------------------------------
            if size(KC3_27_Anggota_C2_Temp{1,iFitur},1) ~= 0            
                if size(KC3_27_Anggota_C2_Temp{1,iFitur}{iFold,1},1) ~= 0                  
                    %---------------------------------------------------------
                    % Kondisi kalau baris datanya cuma 1, ga usah hitung mean
                    %---------------------------------------------------------
                    if size(KC3_27_Anggota_C2_Temp{1,iFitur}{iFold,1},1) == 1
                        KC3_30_Mean_C2_Temp{1,iFitur}{iFold,1}(1,:) = KC3_27_Anggota_C2_Temp{1,iFitur}{iFold,1}(:,1:iFitur); %Nambahin "(:,1:iFitur)" doang
                    else KC3_30_Mean_C2_Temp{1,iFitur}{iFold,1}(1,:) = mean(KC3_27_Anggota_C2_Temp{1,iFitur}{iFold,1}(:,1:iFitur));       
                    end                  
                end
            end         
            %---------------------------------------------------------------------------------------------------------------
            % Prevent Fold "KC3_28_Mean_C2_Temp" yang hilang karena tidak dianggap ada oleh matLab, dibuat matrix kosong []  
            %---------------------------------------------------------------------------------------------------------------
            if size(KC3_26_Anggota_C1_Temp{1,iFitur}{iFold,1},1) == size(KC3_02_Train{1,iFitur}{iFold,1},1)
                KC3_30_Mean_C2_Temp{1,iFitur}{iFold,1} = [];
            end
        
            %-----------------------------------------------------------
            % Pembulatan nilai MEAN --> C1 "new Temp" dan C2 "new Temp"
            %-----------------------------------------------------------
            for iSeleksiFitur = 1 : iFitur                        
                %---------
                % MEAN C1
                %---------
                nilaiMeanC1 = KC3_29_Mean_C1_Temp{1,iFitur}{iFold,1}(1,iSeleksiFitur);
                pembulatanC1 = pembulatanMEAN_fix(nilaiMeanC1);
                KC3_31_Titik_C1_Temp{1,iFitur}{iFold,1}(1,iSeleksiFitur) = pembulatanC1;            
                %---------
                % MEAN C2
                %---------                
                if size(KC3_30_Mean_C2_Temp{1,iFitur}{iFold,1},1) ~= 0                    
                    nilaiMeanC2 = KC3_30_Mean_C2_Temp{1,iFitur}{iFold,1}(1,iSeleksiFitur);
                    pembulatanC2 = pembulatanMEAN_fix(nilaiMeanC2);
                    KC3_32_Titik_C2_Temp{1,iFitur}{iFold,1}(1,iSeleksiFitur) = pembulatanC2;
                end                
                %------------------------------------------------------------------------------------------------
                % Prevent Fold < 10 untuk anggota C2, jadi metrik kosong di akhir dianggap tidak ada sama matLab    
                %------------------------------------------------------------------------------------------------
                if size(KC3_26_Anggota_C1_Temp{1,iFitur}{iFold,1},1) == size(KC3_02_Train{1,iFitur}{iFold,1},1)
                    KC3_32_Titik_C2_Temp{1,iFitur}{iFold,1} = [];
                end            
            end
            clear iSeleksiFitur nilaiMeanC1 nilaiMeanC2 pembulatanC1 pembulatanC2
            
            %------------------------------------------------------------------------------
            % Hitung hamming distance masing-masing fitur terhadap "C1_temp" dan "C2_temp"
            %------------------------------------------------------------------------------
            for iKolomCluster = 1 : iFitur
                for iBarisCluster = 1 : size(KC3_02_Train{1,iFitur}{iFold,1},1)              
                    %-------------------------------------------
                    % Hitung jarak data ke titik cluster "temp"
                    %-------------------------------------------
                    data = KC3_02_Train{1,iFitur}{iFold,1}(iBarisCluster,iKolomCluster);
                    %-------------------------------
                    % Jarak tiap fitur ke "C1_temp"
                    %-------------------------------
                    C1 = KC3_31_Titik_C1_Temp{1,iFitur}{iFold,1}(1,iKolomCluster);                                
                    jarakHamming = hammingDistance_fix(data,C1);
                    KC3_33_HamDist_C1_Temp{1,iFitur}{iFold,1}(iBarisCluster,iKolomCluster) = jarakHamming;
                    %------------------------------
                    % Jarak tiap fitur ke "C2_temp"
                    %------------------------------                
                    if size(KC3_32_Titik_C2_Temp{1,iFitur}{iFold,1},1) ~= 0                                        
                        C2 = KC3_32_Titik_C2_Temp{1,iFitur}{iFold,1}(1,iKolomCluster);                  
                        jarakHamming = hammingDistance_fix(data,C2);
                        KC3_34_HamDist_C2_Temp{1,iFitur}{iFold,1}(iBarisCluster,iKolomCluster) = jarakHamming;                    
                    else KC3_34_HamDist_C2_Temp{1,iFitur}{iFold,1} = [];
                    end                
                end
            end
            clear iBarisCluster jarakHamming data C1 C2 iKolomCluster;
            
            %---------------------------------------------------------------------------
            % Menghitung rata-rata hamming distance "temp" C1 dan C2 pada seleksi fitur
            %---------------------------------------------------------------------------
            KC3_35_Avg_HamDist_Temp{1,iFitur}{iFold,1}(:,1) = mean(KC3_33_HamDist_C1_Temp{1,iFitur}{iFold,1},2); % Rata-rata per baris
            %---------------------------------------------------------
            % Selama tidak ada metrik kosong pada hamming distance C2
            %---------------------------------------------------------
            if size(KC3_34_HamDist_C2_Temp{1,iFitur}{iFold,1},1) ~= 0 
                KC3_35_Avg_HamDist_Temp{1,iFitur}{iFold,1}(:,2) = mean(KC3_34_HamDist_C2_Temp{1,iFitur}{iFold,1},2); % Rata-rata per baris
            %--------------------------------------------------
            % Kalau ADA metrik kosong pada hamming distance C2
            %--------------------------------------------------
            else
                for iKosong = 1 : size(KC3_02_Train{1,iFitur}{iFold,1},1)
                    KC3_35_Avg_HamDist_Temp{1,iFitur}{iFold,1}(iKosong,2) = 9999; % Sengaja dibuat jauh jaraknya
                end            
            end 
            clear iKosong;                                  
            
            %----------------------------------------------------------------------------------------
            % Penentuan status anggota "C1_temp" atau "C2_temp" berdasarkan jarak rata-rata terdekat
            %----------------------------------------------------------------------------------------
            for iBarisAvg = 1 : size(KC3_02_Train{1,iFitur}{iFold,1},1)        
                averageC1 = KC3_35_Avg_HamDist_Temp{1,iFitur}{iFold,1}(iBarisAvg,1);            
                averageC2 = KC3_35_Avg_HamDist_Temp{1,iFitur}{iFold,1}(iBarisAvg,2);                                 
                if averageC1 > averageC2                                
                    KC3_35_Avg_HamDist_Temp{1,iFitur}{iFold,1}(iBarisAvg,3) = 22222;
                else KC3_35_Avg_HamDist_Temp{1,iFitur}{iFold,1}(iBarisAvg,3) = 11111;
                end                                                                                                                                                                  
            end
            clear iBarisAvg averageC1 averageC2; 
                        
            %------------------------------------------------------------------------
            % Pengelompokan data "C1_Temp" dan "C2_Temp" berdasarkan 11111 dan 22222
            %------------------------------------------------------------------------
            fgC1 = 0;
            fgC2 = 0;
            for iBarisKelompok = 1 : size(KC3_02_Train{1,iFitur}{iFold,1},1)  
                if KC3_35_Avg_HamDist_Temp{1,iFitur}{iFold,1}(iBarisKelompok,3) == 11111     
                    fgC1 = fgC1 + 1;
                    KC3_36_Anggota_C1_newTemp{1,iFitur}{iFold,1}(fgC1,:) = KC3_02_Train{1,iFitur}{iFold,1}(iBarisKelompok,1:iFitur+2);                
                else                    
                    fgC2 = fgC2 + 1;
                    KC3_21_Anggota_C2_newTemp{1,iFitur}{iFold,1}(fgC2,:) = KC3_02_Train{1,iFitur}{iFold,1}(iBarisKelompok,1:iFitur+2);                                        
                end                                                                  
            end
            %-----------------------------------------------------------------------------------------------------------------
            % Prevent Fold "KC3_21_Anggota_C2_new" yang hilang karena tidak dianggap ada oleh matLab, dibuat matrix kosong []  
            %-----------------------------------------------------------------------------------------------------------------
            if size(KC3_36_Anggota_C1_newTemp{1,iFitur}{iFold,1},1) == size(KC3_02_Train{1,iFitur}{iFold,1},1)
                KC3_21_Anggota_C2_newTemp{1,iFitur}{iFold,1} = [];
            end        
            clear fgC1 fgC2 iBarisKelompok;            
            
            %---------------------------------
            % Nilai "Temp" dipindah ke "Awal"
            %---------------------------------
            KC3_23_Anggota_C1_Awal{1,iFitur}{iFold,1} = KC3_26_Anggota_C1_Temp{1,iFitur}{iFold,1};
            KC3_24_Anggota_C2_Awal{1,iFitur}{iFold,1} = KC3_27_Anggota_C2_Temp{1,iFitur}{iFold,1};
            
            %------------------------------------
            % Nilai "NewTemp" dipindah ke "Temp"
            %------------------------------------
            KC3_26_Anggota_C1_Temp{1,iFitur}{iFold,1} = KC3_36_Anggota_C1_newTemp{1,iFitur}{iFold,1};
            KC3_27_Anggota_C2_Temp{1,iFitur}{iFold,1} = KC3_21_Anggota_C2_newTemp{1,iFitur}{iFold,1};            
            
            %------------------------------------------------
            % Kondisi kalau sudah konvergen, "Awal" = "Temp"
            %------------------------------------------------
            if size(KC3_23_Anggota_C1_Awal{1,iFitur}{iFold,1},1) == size(KC3_26_Anggota_C1_Temp{1,iFitur}{iFold,1},1)
                if KC3_23_Anggota_C1_Awal{1,iFitur}{iFold,1} == KC3_26_Anggota_C1_Temp{1,iFitur}{iFold,1}
                    konvergen = false;                
                    break
                else
                    KC3_44_JumlahIterasi{1,iFitur}{iFold,1} = KC3_44_JumlahIterasi{1,iFitur}{iFold,1} + 1; %counter iterasi
                    %------------------------------
                    % Pembatasan iterasi konvergen
                    %------------------------------
                    if KC3_44_JumlahIterasi{1,iFitur}{iFold,1} == 1000 %pembatasan 1000 iterasi
                        konvergen = false;
                        break;
                    end
                end
            end            
        %--                                                    
        end 
        clear KC3_36_Anggota_C1_newTemp KC3_21_Anggota_C2_newTemp;