tic

%--------------------------------------
% Tear-down semua display dan variable
%--------------------------------------
clc; clear;

%---------------
% Load file RFF 
%---------------
KC3_01_RFF = csvread('03_SeleksiFitur\KC3_RFF\KC3_RFF.csv');

%-------------
% K-Fold = 5
%-------------
k = 5;
vektorKC3 = KC3_01_RFF(:,1);
rng(1);
cvFolds = crossvalind('Kfold', vektorKC3, k);
clear vektorKC3; 
    
disp('KC3_RFF Calculation in progress...');

for iFitur = 39 : -1 : 1
%---
    for iFold = 1 : k
    %---
    
        %-------------------------------------------
        % Untuk menghitung iterasi hingga konvergen
        %-------------------------------------------
        KC3_44_JumlahIterasi{1,iFitur}{iFold,1} = 0;
        
        %-------------------------------------
        % Penetapan data TRAINING dan TESTING
        %-------------------------------------
        testIdx = (cvFolds == iFold);                
        KC3_00_TrainIdx(:,iFold) = ~testIdx;        
        
        %------------------------------------------------------------------
        % Pembagian data TRANING dan TESTING berdasarkan "KC3_00_TrainIdx"        
        %------------------------------------------------------------------
        iTraining = 1; 
        iTesting = 1;                     
        for iBarisData = 1 : length(KC3_01_RFF)            
            if KC3_00_TrainIdx(iBarisData,iFold) == 1 %---- TRAINING                 
                KC3_02_Train{1,iFitur}{iFold,1}(iTraining,1:iFitur) = KC3_01_RFF(iTraining,1:iFitur); 
                KC3_02_Train{1,iFitur}{iFold,1}(iTraining,iFitur+1) = KC3_01_RFF(iTraining,40); % Tambah kelas
                KC3_02_Train{1,iFitur}{iFold,1}(iTraining,iFitur+2) = iBarisData; % Tambah urutan data
                iTraining = iTraining + 1;            
            else %---- TESTING                                        
                KC3_03_Test{1,iFitur}{iFold,1}(iTesting,1:iFitur) = KC3_01_RFF(iTesting,1:iFitur);            
                KC3_03_Test{1,iFitur}{iFold,1}(iTesting,iFitur+1) = KC3_01_RFF(iTesting,40); % Tambah kelas
                KC3_03_Test{1,iFitur}{iFold,1}(iTesting,iFitur+2) = iBarisData; % Tambah urutan data
                iTesting = iTesting + 1;
            end                        
        end
        clear iBarisData iTesting iTraining;
        
        %------------------------------------------------------
        % Pembagian data TRAINING yang kelasnya FALSE dan TRUE
        %------------------------------------------------------
        fgFalse = 0;
        fgTrue = 0;        
        for iJumlahTrain = 1 : size(KC3_02_Train{1,iFitur}{iFold,1},1)  
            %---- FALSE
            if KC3_02_Train{1,iFitur}{iFold,1}(iJumlahTrain,iFitur+1) == 0               
                fgFalse = fgFalse + 1;
                KC3_04_Train_False{1,iFitur}{iFold,1}(fgFalse,:) = KC3_02_Train{1,iFitur}{iFold,1}(iJumlahTrain,:);             
            %---- TRUE
            else 
                fgTrue = fgTrue + 1;
                KC3_05_Train_True{1,iFitur}{iFold,1}(fgTrue,:) = KC3_02_Train{1,iFitur}{iFold,1}(iJumlahTrain,:); 
            end                        
        end
        clear fgFalse fgTrue iJumlahTrain;                      
                                 
        %--------------------------------------------------------------------------------------
        % Cek pemilihan titik C1 jangan sampai pilih yang duplikat dengan kelas berbeda (TRUE)
        %--------------------------------------------------------------------------------------
        kFalse{1,iFitur}{iFold,1} = randperm(size(KC3_04_Train_False{1,iFitur}{iFold,1},1)); % acak urutan data "trainingFalse"
        TrainTrue{iFold,1} = KC3_05_Train_True{1,39}{iFold,1};
        urutan = 1;
        duplikatC1 = true;
        while duplikatC1                        
            TrainTrue{iFold,1}(end+1,:) = KC3_04_Train_False{1,39}{iFold,1}(kFalse{1,39}{iFold,1}(1,urutan),:);
            %----------------------------------------------
            % Kalau jumlah GAK sama, berarti NO duplikasi
            %----------------------------------------------
            if size(KC3_05_Train_True{1,39}{iFold,1},1) ~= size(unique(TrainTrue{iFold,1}(:,1:39),'rows'),1)
                duplikatC1 = false;
                KC3_06_Titik_C1{1,iFitur}{iFold,1} = KC3_04_Train_False{1,iFitur}{iFold,1}(kFalse{1,39}{iFold,1}(1,urutan),:); % urutan pertama hasil acak, diambil sebagai C1  
            %---------------
            % ADA duplikasi
            %---------------
            else                
                TrainTrue{iFold,1}(end,:) = [];
                urutan = urutan + 1;
            end            
        end 
        clear urutan duplikatC1 TrainTrue;
        
        %--------------------------------------------------------------------------------------
        % Cek pemilihan titik C2 jangan sampai pilih yang duplikat dengan kelas berbeda (FALSE)
        %--------------------------------------------------------------------------------------
        kTrue{1,iFitur}{iFold,1} = randperm(size(KC3_05_Train_True{1,iFitur}{iFold,1},1)); % acak urutan data "trainingTrue"         
        TrainFalse{iFold,1} = KC3_04_Train_False{1,39}{iFold,1};
        urutan = 1;
        duplikatC2 = true;
        while duplikatC2                        
            TrainFalse{iFold,1}(end+1,:) = KC3_05_Train_True{1,39}{iFold,1}(kTrue{1,39}{iFold,1}(1,urutan),:);
            %----------------------------------------------
            % Kalau jumlah GAK sama, berarti NO duplikasi
            %----------------------------------------------
            if size(KC3_04_Train_False{1,39}{iFold,1},1) ~= size(unique(TrainFalse{iFold,1}(:,1:39),'rows'),1)
                duplikatC2 = false;
                KC3_07_Titik_C2{1,iFitur}{iFold,1} = KC3_05_Train_True{1,iFitur}{iFold,1}(kTrue{1,39}{iFold,1}(1,urutan),:); % urutan pertama hasil acak, diambil sebagai C1  
            %---------------
            % ADA duplikasi
            %---------------
            else                
                TrainFalse{iFold,1}(end,:) = [];
                urutan = urutan + 1;
            end            
        end 
        clear urutan duplikatC2 TrainFalse;       

%         %---------------------------------------------------
%         % Tentukan C1 dari kumpulan kelas FALSE secara acak
%         %--------------------------------------------------- 
%         kFalse{1,iFitur}{iFold,1} = randperm(size(KC3_04_Train_False{1,39}{iFold,1},1)); % acak urutan data "trainingFalse"
%         KC3_06_Titik_C1{1,iFitur}{iFold,1} = KC3_04_Train_False{1,iFitur}{iFold,1}(kFalse{1,39}{iFold,1}(1,1),:); % urutan pertama hasil acak, diambil sebagai C1  
%         
%         %--------------------------------------------------
%         % Tentukan C2 dari kumpulan kelas TRUE secara acak
%         %--------------------------------------------------        
%         kTrue{1,iFitur}{iFold,1} = randperm(size(KC3_05_Train_True{1,39}{iFold,1},1)); % acak urutan data "trainingTrue"         
%         KC3_07_Titik_C2{1,iFitur}{iFold,1} = KC3_05_Train_True{1,iFitur}{iFold,1}(kTrue{1,39}{iFold,1}(1,1),:); % urutan pertama hasil acak, diambil sebagai C2         
        
%==============================================================================================
%                                    ==  FASE 1  ===
%==============================================================================================
        
        %----------------------------------------------------------------
        % Hitung hamming distance masing-masing fitur terhadap C1 dan C2
        %----------------------------------------------------------------
        for iKolomCluster = 1 : iFitur
            for iBarisCluster = 1 : size(KC3_02_Train{1,iFitur}{iFold,1},1)              
                %------------------------------------
                % Hitung jarak data ke titik cluster
                %------------------------------------
                data = KC3_02_Train{1,iFitur}{iFold,1}(iBarisCluster,iKolomCluster);

                %------------------------
                % Jarak tiap fitur ke C1
                %------------------------
                C1 = KC3_06_Titik_C1{1,iFitur}{iFold,1}(1,iKolomCluster);                                
                jarakHamming = hammingDistance_fix(data,C1);
                KC3_08_HamDist_C1{1,iFitur}{iFold,1}(iBarisCluster,iKolomCluster) = jarakHamming;

                %------------------------
                % Jarak tiap fitur ke C2
                %------------------------
                C2 = KC3_07_Titik_C2{1,iFitur}{iFold,1}(1,iKolomCluster);                                
                jarakHamming = hammingDistance_fix(data,C2);
                KC3_09_HamDist_C2{1,iFitur}{iFold,1}(iBarisCluster,iKolomCluster) = jarakHamming;                                           
            end 
        end
        clear iBarisCluster jarakHamming data C1 C2 iKolomCluster;
        
        %-----------------------------------------------------------------------
        % Menghitung rata-rata setiap baris hamming distance pada seleksi fitur
        %-----------------------------------------------------------------------        
        KC3_10_Avg_HamDist{1,iFitur}{iFold,1}(:,1) = mean(KC3_08_HamDist_C1{1,iFitur}{iFold,1},2); % Rata-rata per baris
        KC3_10_Avg_HamDist{1,iFitur}{iFold,1}(:,2) = mean(KC3_09_HamDist_C2{1,iFitur}{iFold,1},2); % Rata-rata per baris
        
        %-------------------------------------------------------------------
        % Penentuan anggota C1 atau C2 berdasarkan jarak rata-rata terdekat
        %-------------------------------------------------------------------
        for iBarisAvg = 1 : size(KC3_02_Train{1,iFitur}{iFold,1},1)
            averageC1 = KC3_10_Avg_HamDist{1,iFitur}{iFold,1}(iBarisAvg,1);
            averageC2 = KC3_10_Avg_HamDist{1,iFitur}{iFold,1}(iBarisAvg,2);                                    
            if averageC1 > averageC2                
                KC3_10_Avg_HamDist{1,iFitur}{iFold,1}(iBarisAvg,3) = 22222;
            else KC3_10_Avg_HamDist{1,iFitur}{iFold,1}(iBarisAvg,3) = 11111;
            end                                                              
        end
        clear iBarisAvg averageC1 averageC2;
           
        %----------------------------------------------------------
        % Pengelompokan data C1 dan C2 berdasarkan 11111 dan 22222
        %----------------------------------------------------------
        fgC1 = 0;
        fgC2 = 0;
        for iBarisKelompok = 1 : size(KC3_02_Train{1,iFitur}{iFold,1},1)  
            if KC3_10_Avg_HamDist{1,iFitur}{iFold,1}(iBarisKelompok,3) == 11111     
                fgC1 = fgC1 + 1;
                KC3_11_Anggota_C1{1,iFitur}{iFold,1}(fgC1,:) = KC3_02_Train{1,iFitur}{iFold,1}(iBarisKelompok,1:iFitur+2);                
            else
                fgC2 = fgC2 + 1;
                KC3_12_Anggota_C2{1,iFitur}{iFold,1}(fgC2,:) = KC3_02_Train{1,iFitur}{iFold,1}(iBarisKelompok,1:iFitur+2);
            end                        
        end
        %-------------------------------------------------------------------------------------------------------------
        % Prevent Fold "KC3_12_Anggota_C2" yang hilang karena tidak dianggap ada oleh matLab, dibuat matrix kosong []  
        %-------------------------------------------------------------------------------------------------------------
        if size(KC3_11_Anggota_C1{1,iFitur}{iFold,1},1) == size(KC3_02_Train{1,iFitur}{iFold,1},1)
            KC3_12_Anggota_C2{1,iFitur}{iFold,1} = [];
        end        
        clear fgC1 fgC2 iBarisKelompok;    
        
        %----------------------------------
        % Hitung MEAN per fitur anggota C1
        %----------------------------------
        KC3_13_Mean_C1{1,iFitur}{iFold,1}(1,:) = mean(KC3_11_Anggota_C1{1,iFitur}{iFold,1}(:,1:iFitur));                 
        
        %----------------------------------
        % Hitung MEAN per fitur anggota C2
        %----------------------------------
        if size(KC3_12_Anggota_C2{1,iFitur},1) ~= 0            
            if size(KC3_12_Anggota_C2{1,iFitur}{iFold,1},1) ~= 0                  
                %---------------------------------------------------------
                % Kondisi kalau baris datanya cuma 1, ga usah hitung mean
                %---------------------------------------------------------
                if size(KC3_12_Anggota_C2{1,iFitur}{iFold,1},1) == 1
                    KC3_14_Mean_C2{1,iFitur}{iFold,1}(1,:) = KC3_12_Anggota_C2{1,iFitur}{iFold,1};
                else KC3_14_Mean_C2{1,iFitur}{iFold,1}(1,:) = mean(KC3_12_Anggota_C2{1,iFitur}{iFold,1}(:,1:iFitur));       
                end                  
            end            
        end         
        %----------------------------------------------------------------------------------------------------------
        % Prevent Fold "KC3_14_Mean_C2" yang hilang karena tidak dianggap ada oleh matLab, dibuat matrix kosong []  
        %----------------------------------------------------------------------------------------------------------
        if size(KC3_11_Anggota_C1{1,iFitur}{iFold,1},1) == size(KC3_02_Train{1,iFitur}{iFold,1},1)
            KC3_14_Mean_C2{1,iFitur}{iFold,1} = [];
        end
        
        %-------------------------------------------------
        % Pembulatan nilai MEAN --> C1 "new" dan C2 "new"
        %-------------------------------------------------        
        for iSeleksiFitur = 1 : iFitur                        
            %---------
            % MEAN C1
            %---------
            nilaiMeanC1 = KC3_13_Mean_C1{1,iFitur}{iFold,1}(1,iSeleksiFitur);
            pembulatanC1 = pembulatanMEAN_fix(nilaiMeanC1);
            KC3_15_Titik_C1_New{1,iFitur}{iFold,1}(1,iSeleksiFitur) = pembulatanC1;            
            %---------
            % MEAN C2
            %---------
            if size(KC3_14_Mean_C2{1,iFitur},1) ~= 0
                if size(KC3_14_Mean_C2{1,iFitur}{iFold,1},1) ~= 0
                    nilaiMeanC2 = KC3_14_Mean_C2{1,iFitur}{iFold,1}(1,iSeleksiFitur);
                    pembulatanC2 = pembulatanMEAN_fix(nilaiMeanC2);
                    KC3_16_Titik_C2_New{1,iFitur}{iFold,1}(1,iSeleksiFitur) = pembulatanC2;
                end
            end             
            %------------------------------------------------------------------------------------------------
            % Prevent Fold < 10 untuk anggota C2, jadi metrik kosong di akhir dianggap tidak ada sama matLab    
            %------------------------------------------------------------------------------------------------
            if length(KC3_11_Anggota_C1{1,iFitur}{iFold,1}) == size(KC3_02_Train{1,iFitur}{iFold,1},1)
                KC3_16_Titik_C2_New{1,iFitur}{iFold,1} = [];
            end            
        end
        clear iSeleksiFitur nilaiMeanC1 nilaiMeanC2 pembulatanC1 pembulatanC2                        
        
%==============================================================================================
%                                    ==  FASE 2  ===
%==============================================================================================        
            
        %----------------------------------------------------------------------------
        % Hitung hamming distance masing-masing fitur terhadap "C1_new" dan "C2_new"
        %----------------------------------------------------------------------------
        for iKolomCluster = 1 : iFitur
            for iBarisCluster = 1 : size(KC3_02_Train{1,iFitur}{iFold,1},1)              
                %-------------------------------------------
                % Hitung jarak data ke titik cluster "new"
                %-------------------------------------------
                data = KC3_02_Train{1,iFitur}{iFold,1}(iBarisCluster,iKolomCluster);

                %------------------------------
                % Jarak tiap fitur ke "C1_new"
                %------------------------------
                C1 = KC3_15_Titik_C1_New{1,iFitur}{iFold,1}(1,iKolomCluster);                                
                jarakHamming = hammingDistance_fix(data,C1);
                KC3_17_HamDist_C1_new{1,iFitur}{iFold,1}(iBarisCluster,iKolomCluster) = jarakHamming;

                %------------------------------
                % Jarak tiap fitur ke "C2_new"
                %------------------------------                
                if size(KC3_16_Titik_C2_New{1,iFitur}{iFold,1},1) ~= 0                                        
                    C2 = KC3_16_Titik_C2_New{1,iFitur}{iFold,1}(1,iKolomCluster);                  
                    jarakHamming = hammingDistance_fix(data,C2);
                    KC3_18_HamDist_C2_new{1,iFitur}{iFold,1}(iBarisCluster,iKolomCluster) = jarakHamming;                    
                else
                    KC3_18_HamDist_C2_new{1,iFitur}{iFold,1} = [];
                end                
            end
        end
        clear iBarisCluster jarakHamming data C1 C2 iKolomCluster;                        
        
        %-----------------------------------------------------------------------
        % Menghitung rata-rata setiap baris hamming distance pada seleksi fitur
        %-----------------------------------------------------------------------        
        KC3_19_Avg_HamDist_new{1,iFitur}{iFold,1}(:,1) = mean(KC3_17_HamDist_C1_new{1,iFitur}{iFold,1},2); % Rata-rata per baris
            %---------------------------------------------------------
            % Selama tidak ada metrik kosong pada hamming distance C2
            %---------------------------------------------------------
        if length(KC3_18_HamDist_C2_new{1,iFitur}{iFold,1}) ~= 0 
            KC3_19_Avg_HamDist_new{1,iFitur}{iFold,1}(:,2) = mean(KC3_18_HamDist_C2_new{1,iFitur}{iFold,1},2); % Rata-rata per baris
            %--------------------------------------------------
            % Kalau ADA metrik kosong pada hamming distance C2
            %--------------------------------------------------
        else
            for iKosong = 1 : length(KC3_02_Train{1,iFitur}{iFold,1})
                KC3_19_Avg_HamDist_new{1,iFitur}{iFold,1}(iKosong,2) = 9999; % Sengaja dibuat jauh jaraknya
            end            
        end 
        clear iKosong;
        
        %-------------------------------------------------------------------------------
        % Penentuan anggota "C1_new" atau "C2_new" berdasarkan jarak rata-rata terdekat
        %-------------------------------------------------------------------------------
        for iBarisAvg = 1 : size(KC3_02_Train{1,iFitur}{iFold,1},1)        
            averageC1 = KC3_19_Avg_HamDist_new{1,iFitur}{iFold,1}(iBarisAvg,1);            
            averageC2 = KC3_19_Avg_HamDist_new{1,iFitur}{iFold,1}(iBarisAvg,2);                                 
            if averageC1 > averageC2                                
                KC3_19_Avg_HamDist_new{1,iFitur}{iFold,1}(iBarisAvg,3) = 22222;
            else KC3_19_Avg_HamDist_new{1,iFitur}{iFold,1}(iBarisAvg,3) = 11111;
            end                                                                                                                                                                  
        end
        clear iBarisAvg averageC1 averageC2;           
        
        %----------------------------------------------------------------------
        % Pengelompokan data "C1_new" dan "C2_new" berdasarkan 11111 dan 22222
        %----------------------------------------------------------------------
        fgC1 = 0;
        fgC2 = 0;
        for iBarisKelompok = 1 : size(KC3_02_Train{1,iFitur}{iFold,1},1)  
            if KC3_19_Avg_HamDist_new{1,iFitur}{iFold,1}(iBarisKelompok,3) == 11111     
                fgC1 = fgC1 + 1;
                KC3_20_Anggota_C1_new{1,iFitur}{iFold,1}(fgC1,:) = KC3_02_Train{1,iFitur}{iFold,1}(iBarisKelompok,1:iFitur+2);                
            else
                fgC2 = fgC2 + 1;
                KC3_21_Anggota_C2_new{1,iFitur}{iFold,1}(fgC2,:) = KC3_02_Train{1,iFitur}{iFold,1}(iBarisKelompok,1:iFitur+2);
            end                        
        end
        %-----------------------------------------------------------------------------------------------------------------
        % Prevent Fold "KC3_21_Anggota_C2_new" yang hilang karena tidak dianggap ada oleh matLab, dibuat matrix kosong []  
        %-----------------------------------------------------------------------------------------------------------------
        if length(KC3_20_Anggota_C1_new{1,iFitur}{iFold,1}) == length(KC3_02_Train{1,iFitur}{iFold,1})
            KC3_21_Anggota_C2_new{1,iFitur}{iFold,1} = [];
        end        
        clear fgC1 fgC2 iBarisKelompok;  
        
%==============================================================================================
%                                    ==  WHILE  ===
%==============================================================================================                        
        
        %------------------------------------------------------------------------------------------
        % 1. Cek apakah anggota C1 dan C2 yang lama sudah sama dengan yang baru? If ya = konvergen
        % 2. If tidak = Hitung lagi, cari anggota C1 dan C2 yang baru
        %------------------------------------------------------------------------------------------
        KC3_22_____________________ = 0;
        KC3_23_Anggota_C1_Awal{1,iFitur}{iFold,1} = KC3_11_Anggota_C1{1,iFitur}{iFold,1};
        KC3_24_Anggota_C2_Awal{1,iFitur}{iFold,1} = KC3_12_Anggota_C2{1,iFitur}{iFold,1};         
        KC3_25_____________________ = 0;        
        KC3_26_Anggota_C1_Temp{1,iFitur}{iFold,1} = KC3_20_Anggota_C1_new{1,iFitur}{iFold,1};               
        %------------------------------------------------------------------------------------------------------------------
        % Prevent Fold "KC3_27_Anggota_C2_Temp" yang hilang karena tidak dianggap ada oleh matLab, dibuat matrix kosong []
        %------------------------------------------------------------------------------------------------------------------
        if size(KC3_24_Anggota_C2_Awal{1,iFitur}{iFold,1},1) ~=0            
            KC3_27_Anggota_C2_Temp{1,iFitur}{iFold,1} = KC3_24_Anggota_C2_Awal{1,iFitur}{iFold,1};
        else KC3_27_Anggota_C2_Temp{1,iFitur}{iFold,1} = [];
        end                                                               
        KC3_28_____________________ = 0;        
                                
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
                        KC3_30_Mean_C2_Temp{1,iFitur}{iFold,1}(1,:) = KC3_27_Anggota_C2_Temp{1,iFitur}{iFold,1};
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
                for iBarisCluster = 1 : length(KC3_02_Train{1,iFitur}{iFold,1})              
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
                    if length(KC3_32_Titik_C2_Temp{1,iFitur}{iFold,1}) ~= 0                                        
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
            if length(KC3_34_HamDist_C2_Temp{1,iFitur}{iFold,1}) ~= 0 
                KC3_35_Avg_HamDist_Temp{1,iFitur}{iFold,1}(:,2) = mean(KC3_34_HamDist_C2_Temp{1,iFitur}{iFold,1},2); % Rata-rata per baris
            %--------------------------------------------------
            % Kalau ADA metrik kosong pada hamming distance C2
            %--------------------------------------------------
            else
                for iKosong = 1 : length(KC3_02_Train{1,iFitur}{iFold,1})
                    KC3_35_Avg_HamDist_Temp{1,iFitur}{iFold,1}(iKosong,2) = 9999; % Sengaja dibuat jauh jaraknya
                end            
            end 
            clear iKosong;                                  
            
            %----------------------------------------------------------------------------------------
            % Penentuan status anggota "C1_temp" atau "C2_temp" berdasarkan jarak rata-rata terdekat
            %----------------------------------------------------------------------------------------
            for iBarisAvg = 1 : length(KC3_02_Train{1,iFitur}{iFold,1})        
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
            for iBarisKelompok = 1 : length(KC3_02_Train{1,iFitur}{iFold,1})  
                if KC3_35_Avg_HamDist_Temp{1,iFitur}{iFold,1}(iBarisKelompok,3) == 11111     
                    fgC1 = fgC1 + 1;
                    KC3_36_Anggota_C1_newTemp{1,iFitur}{iFold,1}(fgC1,:) = KC3_02_Train{1,iFitur}{iFold,1}(iBarisKelompok,1:iFitur+2);                
                else                    
                    fgC2 = fgC2 + 1;
                    KC3_37_Anggota_C2_newTemp{1,iFitur}{iFold,1}(fgC2,:) = KC3_02_Train{1,iFitur}{iFold,1}(iBarisKelompok,1:iFitur+2);                                        
                end                                                                  
            end
            %-----------------------------------------------------------------------------------------------------------------
            % Prevent Fold "KC3_21_Anggota_C2_new" yang hilang karena tidak dianggap ada oleh matLab, dibuat matrix kosong []  
            %-----------------------------------------------------------------------------------------------------------------
            if length(KC3_36_Anggota_C1_newTemp{1,iFitur}{iFold,1}) == length(KC3_02_Train{1,iFitur}{iFold,1})
                KC3_37_Anggota_C2_newTemp{1,iFitur}{iFold,1} = [];
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
            KC3_27_Anggota_C2_Temp{1,iFitur}{iFold,1} = KC3_37_Anggota_C2_newTemp{1,iFitur}{iFold,1};            
            
            %------------------------------------------------
            % Kondisi kalau sudah konvergen, "Awal" = "Temp"
            %------------------------------------------------
            if length(KC3_23_Anggota_C1_Awal{1,iFitur}{iFold,1}) == length(KC3_26_Anggota_C1_Temp{1,iFitur}{iFold,1})
                if KC3_23_Anggota_C1_Awal{1,iFitur}{iFold,1} == KC3_26_Anggota_C1_Temp{1,iFitur}{iFold,1}
                    konvergen = false;                
                    break
                else
                    KC3_44_JumlahIterasi{1,iFitur}{iFold,1} = KC3_44_JumlahIterasi{1,iFitur}{iFold,1} + 1;
                    %------------------------------
                    % Pembatasan iterasi konvergen
                    %------------------------------
                    if KC3_44_JumlahIterasi{1,iFitur}{iFold,1} == 1000
                        konvergen = false;
                        break;
                    end
                end
            end            
        %--                                                    
        end 
        clear KC3_36_Anggota_C1_newTemp KC3_37_Anggota_C2_newTemp;
        
%==============================================================================================
%                                   ==  TESTING  ===
%==============================================================================================         
        
        %----------------------------------------------------------------
        % Hitung hamming distance TESTING terhadap titik C1 dan C2 temp
        %----------------------------------------------------------------        
        KC3_38________________________ = 0;        
        for iKolomCluster = 1 : iFitur
            for iBarisCluster = 1 : size(KC3_03_Test{1,iFitur}{iFold,1},1)              
                %--------------------------------------------
                % Hitung jarak data TESTING ke titik cluster
                %--------------------------------------------
                data = KC3_03_Test{1,iFitur}{iFold,1}(iBarisCluster,iKolomCluster);

                %--------------------------------
                % Jarak tiap fitur TESTING ke C1
                %--------------------------------
                C1 = KC3_31_Titik_C1_Temp{1,iFitur}{iFold,1}(1,iKolomCluster);                                
                jarakHamming = hammingDistance_fix(data,C1);
                KC3_39_Test_HamDist_C1{1,iFitur}{iFold,1}(iBarisCluster,iKolomCluster) = jarakHamming;

                %--------------------------------
                % Jarak tiap fitur TESTING ke C2
                %--------------------------------
                if size(KC3_32_Titik_C2_Temp{1,iFitur}{iFold,1},1) ~= 0                                        
                    C2 = KC3_32_Titik_C2_Temp{1,iFitur}{iFold,1}(1,iKolomCluster);                                
                    jarakHamming = hammingDistance_fix(data,C2);
                    KC3_40_Test_HamDist_C2{1,iFitur}{iFold,1}(iBarisCluster,iKolomCluster) = jarakHamming;
                else
                    KC3_40_Test_HamDist_C2{1,iFitur}{iFold,1}(iBarisCluster,iKolomCluster) = 999999;
                end                
            end 
        end
        clear iBarisCluster jarakHamming data C1 C2 iKolomCluster;
        
        %-----------------------------------------------------------------------
        % Menghitung rata-rata setiap baris hamming distance pada seleksi fitur
        %-----------------------------------------------------------------------        
        KC3_41_Test_Avg_HamDist{1,iFitur}{iFold,1}(:,1) = mean(KC3_39_Test_HamDist_C1{1,iFitur}{iFold,1},2); % Rata-rata per baris        
        KC3_41_Test_Avg_HamDist{1,iFitur}{iFold,1}(:,2) = mean(KC3_40_Test_HamDist_C2{1,iFitur}{iFold,1},2); % Rata-rata per baris
        
        %-------------------------------------------------------------------
        % Penentuan anggota C1 atau C2 berdasarkan jarak rata-rata terdekat
        %-------------------------------------------------------------------
        for iBarisAvg = 1 : length(KC3_03_Test{1,iFitur}{iFold,1})
            averageC1 = KC3_41_Test_Avg_HamDist{1,iFitur}{iFold,1}(iBarisAvg,1);
            averageC2 = KC3_41_Test_Avg_HamDist{1,iFitur}{iFold,1}(iBarisAvg,2);                                    
            if averageC1 > averageC2                
                KC3_41_Test_Avg_HamDist{1,iFitur}{iFold,1}(iBarisAvg,3) = 22222;
            else KC3_41_Test_Avg_HamDist{1,iFitur}{iFold,1}(iBarisAvg,3) = 11111;
            end                                                              
        end
        clear iBarisAvg averageC1 averageC2;       
        
        %-----------------------------------------------------------------------
        % Pengelompokan data "C1_Test" dan "C2_Test" berdasarkan 11111 dan 22222
        %-----------------------------------------------------------------------
        fgC1 = 0;
        fgC2 = 0;
        for iBarisKelompok = 1 : length(KC3_03_Test{1,iFitur}{iFold,1})              
            if KC3_41_Test_Avg_HamDist{1,iFitur}{iFold,1}(iBarisKelompok,3) == 11111                     
                fgC1 = fgC1 + 1;
                KC3_42_Test_Anggota_C1{1,iFitur}{iFold,1}(fgC1,:) = KC3_03_Test{1,iFitur}{iFold,1}(iBarisKelompok,1:iFitur+2);                
            else     
                fgC2 = fgC2 + 1;
                KC3_43_Test_Anggota_C2{1,iFitur}{iFold,1}(fgC2,:) = KC3_03_Test{1,iFitur}{iFold,1}(iBarisKelompok,1:iFitur+2);                             
            end                                                                  
        end           
        
        %----------------------------------------------------------------------
        % Cek kalau avg kelompoknya C2 semua atau C1 semua,
        % tar dibuat matrik kosong, soalnya matlab menganggap tidak ada matrik
        %----------------------------------------------------------------------
        if fgC1 == size(KC3_03_Test{1,iFitur}{iFold,1},1)
            KC3_43_Test_Anggota_C2{1,iFitur}{iFold,1} = [];                 
        elseif fgC2 == size(KC3_03_Test{1,iFitur}{iFold,1},1)
            KC3_42_Test_Anggota_C1{1,iFitur}{iFold,1} = [];
        end
        clear fgC1 fgC2 iBarisKelompok;                                  
        
        %-----------------------------------------------------------------------------------------------------------------
        % Prevent Fold "KC3_43_Test_Anggota_C2" yang hilang karena tidak dianggap ada oleh matLab, dibuat matrix kosong []  
        %-----------------------------------------------------------------------------------------------------------------
        if size(KC3_42_Test_Anggota_C1{1,iFitur}{iFold,1},1) ~= 0
            if size(KC3_42_Test_Anggota_C1{1,iFitur}{iFold,1},1) == size(KC3_03_Test{1,iFitur}{iFold,1},1)
                KC3_43_Test_Anggota_C2{1,iFitur}{iFold,1} = [];
            end
        end        
        
        %-----------------------------------------------------------------------------------------------------------------
        % Prevent Fold "KC3_42_Test_Anggota_C1" yang hilang karena tidak dianggap ada oleh matLab, dibuat matrix kosong []  
        %-----------------------------------------------------------------------------------------------------------------
        if size(KC3_43_Test_Anggota_C2{1,iFitur}{iFold,1},1) ~= 0
            if size(KC3_43_Test_Anggota_C2{1,iFitur}{iFold,1},1) == size(KC3_03_Test{1,iFitur}{iFold,1},1)
                KC3_42_Test_Anggota_C1{1,iFitur}{iFold,1} = [];
            end
        end   
                                
%==============================================================================================
%                              ==  KC3_45_TP_ && KC3_46_FP_  ===
%==============================================================================================         

        %-----------------------------------------
        % Kalau anggota C2 emang gada sama sekali
        %-----------------------------------------
        countTP = 0;
        countFP = 0;
        if size(KC3_43_Test_Anggota_C2{1,iFitur}{iFold,1},1) == 0
            KC3_45_TP_{1,iFitur}{iFold,1} = 0;
            KC3_46_FP_{1,iFitur}{iFold,1} = 0;
        %---------------------------------------    
        % Ada anggota C2, maka hitung TP dan FP
        %---------------------------------------
        else 
            %--------------------------------
            % Cek anggota C2 untuk TP dan FP
            %--------------------------------
            for iBarisC2 = 1 : size(KC3_43_Test_Anggota_C2{1,iFitur}{iFold,1},1)
                if KC3_43_Test_Anggota_C2{1,iFitur}{iFold,1}(iBarisC2,iFitur+1) == 1
                    countTP = countTP + 1;
                    KC3_45_TP_{1,iFitur}{iFold,1} = countTP;
                else
                    countFP = countFP + 1;
                    KC3_46_FP_{1,iFitur}{iFold,1} = countFP;
                end            
            end                                          
        end
        %--------------------------------------------------
        % Kondisi kalau kelasnya 0 semua atau 1 semua di C2
        %--------------------------------------------------
        if countFP == size(KC3_43_Test_Anggota_C2{1,iFitur}{iFold,1},1)
            KC3_45_TP_{1,iFitur}{iFold,1} = 0;
        elseif countTP == size(KC3_43_Test_Anggota_C2{1,iFitur}{iFold,1},1)
            KC3_46_FP_{1,iFitur}{iFold,1} = 0;
        end
        clear countTP countFP iBarisC2;
                               
%==============================================================================================
%                             ==  KC3_47_FN_ && KC3_48_TN_  ===
%============================================================================================== 
              
        %-----------------------------------------
        % Kalau anggota C1 emang gada sama sekali
        %-----------------------------------------
        countFN = 0;
        countTN = 0;   
        if size(KC3_42_Test_Anggota_C1{1,iFitur}{iFold,1},1) == 0
            KC3_47_FN_{1,iFitur}{iFold,1} = 0;
            KC3_48_TN_{1,iFitur}{iFold,1} = 0;
        %----------------
        % C1 ada anggota
        %----------------
        else    
            %--------------------------------
            % Cek anggota C2 untuk FN dan TN
            %--------------------------------
            for iBarisC2 = 1 : size(KC3_42_Test_Anggota_C1{1,iFitur}{iFold,1},1)
                if KC3_42_Test_Anggota_C1{1,iFitur}{iFold,1}(iBarisC2,iFitur+1) == 1
                    countFN = countFN + 1;
                    KC3_47_FN_{1,iFitur}{iFold,1} = countFN;                
                else
                    countTN = countTN + 1;
                    KC3_48_TN_{1,iFitur}{iFold,1} = countTN;
                end            
            end                    
        end  
        %--------------------------------------------------
        % Kondisi kalau kelasnya 0 semua atau 1 semua di C1
        %--------------------------------------------------
        if countFN == size(KC3_42_Test_Anggota_C1{1,iFitur}{iFold,1},1)
            KC3_48_TN_{1,iFitur}{iFold,1} = 0;
        elseif countTN == size(KC3_42_Test_Anggota_C1{1,iFitur}{iFold,1},1)
            KC3_47_FN_{1,iFitur}{iFold,1} = 0;
        end
        clear countFN countTN iBarisC2;
        
%==============================================================================================
%                                ==  KC3_49_PD && KC3_50_PF  ===
%==============================================================================================
        
        %-----------------
        % PD = tp/(tp+fn)
        %-----------------
        KC3_49_PD{1,iFitur}(iFold,1) = KC3_45_TP_{1,iFitur}{iFold,1}/(KC3_45_TP_{1,iFitur}{iFold,1} + KC3_47_FN_{1,iFitur}{iFold,1});
        %---------
        % Mean PD
        %---------
        KC3_50_Mean_PD(1,iFitur) = (mean(KC3_49_PD{1,iFitur}(:,1)))*100; % Mean hitung ke bawah, bukan ke samping
        
        %-----------------
        % PF = fp/(fp+tn)        
        %-----------------
        KC3_51_PF{1,iFitur}(iFold,1) = KC3_46_FP_{1,iFitur}{iFold,1}/(KC3_46_FP_{1,iFitur}{iFold,1} + KC3_48_TN_{1,iFitur}{iFold,1});
        %---------
        % Mean PF
        %---------
        KC3_52_Mean_PF(1,iFitur) = (mean(KC3_51_PF{1,iFitur}(:,1)))*100; % Mean hitung ke bawah, bukan ke samping
        
        %-----------------------------------------------------
        % Balance = 1 - ( sqrt((0-pf)^2+(1-pd)^2) / sqrt(2) )
        %-----------------------------------------------------        
        KC3_53_BAL{1,iFitur}(iFold,1) = 1 - ( sqrt( ((0 - KC3_51_PF{1,iFitur}(iFold,1))^2) + ((1 - KC3_49_PD{1,iFitur}(iFold,1))^2) ) / sqrt(2) );
        %--------------
        % Mean Balance
        %--------------
        KC3_54_Mean_BAL(1,iFitur) = (mean(KC3_53_BAL{1,iFitur}(:,1)))*100; % Mean hitung ke bawah, bukan ke samping
        
    %---    
    end
%---
end
clear cvFolds iFold testIdx k iFitur konvergen kFalse kTrue;

toc

disp('Saving...');
    tic
        save('04_CBC\KC3_RFF_CBC_FOLD_5.mat');        
    toc
disp('Done!');

load gong %chirp
sound(y,Fs)
clear y Fs;