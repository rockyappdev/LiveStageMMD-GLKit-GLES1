# LiveStageMMD-GLKit-GLES1
LiveStage MMD for iOS with GLKit OpenGLES 1.x

<p>
このプロジェクトは以下の人が対象です。<br>
<ol>
<li>Mac OS Xを使っている方</li>
<li>アップルデベロッパーメンバー</li>
<li>iPhone又はiPadを持っている方</li>
<li>Xcodeを使ってiPhone又はiPadへアプリをインストールした事が有る方</li>
</ol>
<p>
LiveStageMMD-GLKit-GLES1<br>
<ol>
<li>右側の［Download ZIP]をクリックしてzipファイルをダウンロードする。</li>
<li>LiveStageMMD-GLKit-GLES1-master.zipを展開する。</li>
<li>以下のフォルダーの[LVSTG gles1.xcodeproj]をダブルクリックする。</li>
<pre>
   LiveStageMMD-GLKit-GLES1-master
　   +— LVSTG gles1
         +— LVSTG gles1.xcodeproj
</pre>
<li>左側のプロジェクトブラウザーのファイルが全て黒色なのを確認する。</li>
<li>Xcodeが立ち上がったら、ターゲットデバイスを指定する。</li>
<pre>
    iPhone 5 / iPhone5s　など
    iPadやiPhone6は画面が大きいので扱い辛い。
</pre>
<li>Build/Runボタンをおす。</li>
<li>ビルドでエラーが無ければ、シムレーターが立ち上がり、iOSアプリの画面が表示されます。</li>
<li>Xcodeの[All Output]フレームから以下の文字列をメモする</li>
<pre>
   Application/<b>HexID-String-A</b>/Documents/__lvstg-model.xml]
   <b>HexID-String-A</b> = Hex8-Hex4-Hex4-Hex4-Hex12
</pre>

Finderウインドウ左側ナビゲーターにて、
<pre>
    User Home> > ライブラリ
       > Developer
          > CoreSimulator
             > Devices
                > HexID-String-B
                    > data
                       > Containers
                           > Data
                               > Application
                                  > <b>HexID-String-A</b> (from Xcode All Output)
                                     > Documents
                                         __lvstg-model.xml
                                         __lvstg-motion.xml
                                         __lvstg-modelgroup.xml
</pre>
<p>
MikuMikuDanceのモデル、ステージ、モーションのzipファイルを上記のフォルダーへコピーする。
<pre>
  > <b>HexID-String-A</b> (from Xcode All Output)
　　   > Documents
  注意: 現在サポート出来ているのは.pmd,.vmdのみで、.xや.pmxはサポートされていません。
</pre>

<p>
実機へアプリをインストールした場合、iTuneを使ってモデルやモーションの.zipファイルを
アプリ内へコピーして下さい。


<p>
iOS開発の詳細は以下のサイトを見て下さい
<pre>
   https://developer.apple.com/programs
   https://developer.apple.com/ios
</pre>


Twitter: @papipo111

