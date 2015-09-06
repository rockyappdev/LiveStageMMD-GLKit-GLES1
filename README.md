# LiveStageMMD-GLKit-GLES1
LiveStage MMD for iOS with GLKit OpenGLES 1.x

このプロジェクトは以下の人が対象です。
1. Mac OS Xを使っている方
2. アップルデベロッパーメンバー
3. iPhone又はiPadを持っている方
4. Xcodeを使ってiPhone又はiPadへアプリをインストールした事が有る方


LiveStageMMD-GLKit-GLES1
1. 右側の［Download ZIP]をクリックしてzipファイルをダウンロードする。
2. LiveStageMMD-GLKit-GLES1-master.zipを展開する。
3. 以下のフォルダーの[LVSTG gles1.xcodeproj]をダブルクリックする。
   LiveStageMMD-GLKit-GLES1-master
　   +— LVSTG gles1
         +— LVSTG gles1.xcodeproj
4. 左側のプロジェクトブラウザーのファイルが全て黒色なのを確認する。
5. Xcodeが立ち上がったら、ターゲットデバイスを指定する。
    iPhone 5 / iPhone5s　など
    iPadやiPhone6は画面が大きいので扱い辛い。
6. Build/Runボタンをおす。
7. ビルドでエラーが無ければ、シムレーターが立ち上がり、iOSアプリの画面が表示されます。
8. Xcodeの[All Output]フレームから以下の文字列をメモする
   Application/HexID-String-A/Documents/__lvstg-model.xml]
   HexID-String-A = Hex8-Hex4-Hex4-Hex4-Hex12
   Finderウインドウ左側ナビゲーターにて、
    <user home> > ライブラリ
    > Developer
        > CoreSimulator
           > Devices
              > HexID-String-B
                  > data
                     > Containers
                         > Data
                             > Application
                                > HexID-String-A (from Xcode All Output)
                                   > Documents
                                       __lvstg-model.xml
                                       __lvstg-motion.xml
                                       __lvstg-modelgroup.xml

MikuMikuDanceのモデル、ステージ、モーションのzipファイルを上記のフォルダーへコピーする。
  > HexID-String-A (from Xcode All Output)
　　   > Documents
  注意: 現在サポート出来ているのは.pmd,.vmdのみで、.xや.pmxはサポートされていません。



iOS開発の詳細は以下のサイトを見て下さい。
https://developer.apple.com/programs/
https://developer.apple.com/ios/

