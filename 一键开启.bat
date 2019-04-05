@echo off
set d=-d
set kill=1
if exist VVFGAA.lock (
  set backup=1
  set /p MIUI=<VVFGAA.lock
)
set ANDROID_ADB_SERVER_PORT=45037
set t=���з���һ������ 2.1 by VVFGAA ^^^& KizunaAI

title ����� ADB ������%t%
adb version>nul 2>&1
if "%errorlevel%"=="9009" (
  ver|findstr "5.1">nul && (
    echo ����δ�ҵ�Android�����ţ�ADB����������platform-tools��ѱ��ļ�������ļ����С�
    echo ���ӣ�https://dl.google.com/android/repository/platform-tools_r23.1.0-windows.zip
    echo ��������˳�
    pause>nul
    exit
  )
  echo ����δ�ҵ�Android�����ţ�ADB����������platform-tools��ѱ��ļ�������ļ����С����������������ַ
  pause>nul
  start https://dl.google.com/android/repository/platform-tools-latest-windows.zip
  exit
)
call :adb

title ������ֻ�����������%t%
for /f "usebackq tokens=2 delims== " %%i in (`adb %d% shell "dumpsys package me.piebridge.brevent" ^| findstr versionCode`) do set ver=%%i
if "%ver%"=="" (
  echo ����δ��װ���У��˹��߲�֧�ְ��򣩣���������˳�
  pause>nul
  goto end
)
if not %ver% GEQ 30 (
  echo ���󣺺��а汾̫�ͣ���������˳�
  pause>nul
  goto end
)
for /f "usebackq tokens=* " %%i in (`adb %d% shell "getprop ro.boot.serialno"`) do set serialno=%%i
if "%serialno%"=="" for /f "usebackq tokens=* " %%i in (`adb %d% shell "getprop ro.build.date.utc"`) do set serialno=e-%%i
for /f "tokens=*" %%i in ('adb %d% shell "getprop ro.build.version.sdk"') do set sdk=%%i
for /f "tokens=*" %%i in ('adb %d% shell "getprop sys.usb.config"') do set usbconfig=%%i
for /f "tokens=*" %%i in ('adb %d% shell "getprop log.tag.brevent.daemon"') do set daemon=%%i
adb %d% shell "ls -l /sdcard/Android/data/me.piebridge.brevent/" 2>nul | findstr server>nul && set serverlog=1

if "%backup%"=="1" call :backup

call :check
if "%run%"=="1" (
  echo ���з����Ѿ���������ǰģʽ��%user%
  if "%serverlog%"=="1" (
    echo ���й�����־λ���ֻ�/sdcard/Android/data/me.piebridge.brevent/Ŀ¼��
    echo ���ⷴ������Ӧ���ڵ㰴��־��ť�������߷����ʼ�˵���������Ҫ�ʼ�Ӧ�ã�
    echo ���������ʼ����¼���־������Ҫ��ֱ�ӹرմ���
    pause>nul
    call :events
    if "%events%"=="0" echo ���棺û���¼���־�������޷��Զ���������������˳� && pause>nul && goto end
    echo ����������¼���־
    pause>nul
    start events.txt
    goto end
  ) else (
    echo ���������ȡ������־������Ҫ��ֱ�ӹرմ���
    pause>nul
    title ����ȡ������־������%t%
    adb %d% shell "setprop log.tag.BreventServer D"
    adb %d% shell "logcat -G 16M"
    if not exist ������־.txt echo ���ļ����ᱻ�Զ�ɾ������ע����־���ۻ����⡣>������־.txt
    if not exist ������־.txt echo ���ļ����ᱻ�Զ�ɾ������ע����־���ۻ����⡣>������־.txt
    adb %d% logcat -d -b crash>>������־.txt
    adb %d% logcat -d -s BreventServer BreventLoader BreventUI>>������־.txt
    call :events
    echo ����ȡ��־������������־��������ǰ��Ч��
    echo ��˽��飨������ԵĻ����ٴ���һ��������⣬�����б������ռ�����ϸ����־��
    echo �����������־
    pause>nul
    start events.txt
    start ������־.txt
    start ������־.txt
    goto end
  )
)
if "%daemon%"=="1" (
  echo ��⵽�������쳣�رգ����������ڰ���ʧЧ���ر� USB ���Ե�ԭ����ɣ�����������ADB��
  echo ע�⣺���� ADB �з��գ���Ҫͬ�ⲻ���� USB ����ȷ�ϵ�����
  adb %d% tcpip 3035
  echo ���ڰ��ߺ�򿪺���Ӧ��һ�Σ����л��Զ��������񣬰�������˳�
  pause>nul
  goto end
)

title ��׼���������з��񡭡���%t%
adb %d% shell "am force-stop me.piebridge.brevent"
adb %d% shell "am start -n me.piebridge.brevent/.ui.BreventActivity">nul
if %ver% LSS 86 (
  call :events del
  if "%events%"=="0" (
    echo �벻Ҫ�ر���־��¼����������λ�ڿ�����ѡ��-���ԣ�
    echo ��������˳�
    pause>nul
    goto end
  )
)
adb %d% shell "cat /data/data/me.piebridge.brevent/brevent.sh" 2>nul|findstr "exec">nul || set file=0
if "%file%"=="0" call :findlib

title ���������з��񡭡���%t%
if %ver% GEQ 62 (
  if "%file%"=="0" (
    echo ���棺δ����ָ���ļ���׼��ǿ���������񡣿�������ʧ�ܣ��´����������򵼺������б����ߡ�
    adb %d% shell "%libpath%" >BreventLog.txt 2>&1
  ) else (
    adb %d% shell "sh /data/data/me.piebridge.brevent/brevent.sh" >BreventLog.txt 2>&1
  )
) else (
  echo ���棺���Ǻ��е���ʷ�汾���Ѳ���֧�֣��뾡����¡�
  adb %d% shell "sh /sdcard/Android/data/me.piebridge.brevent/brevent.sh" >BreventLog.txt 2>&1
)
call :check
if "%run%"=="0" (
  echo ���з�����ʧ�ܣ��뽫��־������������ https://github.com/brevent/Brevent/issues ��������⡣>>BreventLog.txt
  echo ���з�����ʧ�ܣ��뽫��־������������ https://github.com/brevent/Brevent/issues ��������⡣�����������־
  pause>nul
  start BreventLog.txt
  goto end
)
adb %d% shell "setprop log.tag.brevent.daemon 1"

if "%MIUI%"=="MIUI" call :deviceidle

title ��OK��%t%
del BreventLog.txt
if %sdk% GEQ 26 (
  echo ���棺Android O�����ϵ��豸����Ҫ�رա�USB ���ԡ�����Ҫ���� USB ʹ�÷�ʽ��������Ҫ�����������з���
  if not "%usbconfig%"=="adb" (
    echo ���棺��ǰ�豸��״̬�ᵼ�°��ߺ���з���رգ�����������ADB��ע�⣺���� ADB �з��գ���Ҫͬ�ⲻ���� USB ����ȷ�ϵ�����
    adb %d% tcpip 3035
    echo ���ڰ��ߺ�򿪺���Ӧ��һ�Σ����л��Զ��������񣬰�������˳�
    pause>nul
    goto end
  )
)
echo �����ѿ����������򼴽��Զ��ر�
ping -n 5 127.0.0.1 >nul
goto end

:adb
adb start-server>nul 2>&1 || (
  echo ADB ��������ʧ�ܣ��������ǽ���á�
  echo �����������
  pause>nul
  goto adb
)
for /f "tokens=*" %%t in ('adb %d% get-state') do set adbState=%%t
if not "%adbState%"=="device" (
  echo;
  echo   ADB�����޷��������豸ʵ����������ȷ����
  echo;
  echo   * �豸��������USB���ӡ�
  echo;
  echo   * ������Ѱ�װ���������������ܼ�/���ֵ�һ�������豸ʱ�������װ������
  echo;
  echo   * �豸������ADB���ԣ�������˼�������ӡ�
  echo;
  echo   * �豸û��������������ADB�������ӣ��볢�ԶϿ�USB���ٴ����ӡ�
  echo;
  echo �����������
  setlocal
  set ANDROID_ADB_SERVER_PORT=
  adb kill-server>nul 2>&1
  endlocal
  pause>nul
  goto adb
)
adb %d% unroot>nul
goto :EOF

:findlib
for /f "usebackq tokens=1,* delims== " %%a in (`adb %d% shell "dumpsys package me.piebridge.brevent" ^| findstr legacyNativeLibraryDir`) do set libdir=%%b
for /f "usebackq tokens=1 " %%i in (`adb %d% shell "ls %libdir%"`) do set abi=%%i
set libpath=%libdir%/%abi%/libbrevent.so
goto :EOF

:check
title �������з���״̬������%t%
set user=norun
if %sdk% GEQ 26 set all=-A
for /f "usebackq tokens=1 delims= " %%a in (`adb %d% shell "ps %all%" ^| findstr brevent_server`) do set user=%%a
if "%user%"=="norun" (set run=0) else set run=1
goto :EOF

:backup
title ���������嵥������%t%
set pathx=/data/data/com.android.shell
if %sdk% GEQ 24 set pathx=/data/user_de/0/com.android.shell
adb %d% shell "ls -l %pathx%"|findstr "me.piebridge.brevent.list$">nul && (
  adb %d% pull %pathx%/me.piebridge.brevent.list %serialno%.list>nul 2>&1 && echo �ѱ��ݺ����嵥��
) || if exist %serialno%.list (
  echo �����嵥Ϊ�գ��������ϴ��ڱ��ݡ�
  adb %d% push  %serialno%.list %pathx%/me.piebridge.brevent.list>nul 2>&1 && echo �ѻ�ԭ�����嵥��
) else (
  echo �����嵥Ϊ�գ�������Ҳû�б��ݡ�
)
goto :EOF

:deviceidle
title ���������Ż���%t%
for /f "usebackq tokens=* " %%a in (`adb %d% shell "getprop ro.miui.ui.version.code"`) do set miuiver=%%a
if "%miuiver%"=="" echo ���� MIUI ϵͳ�������������Ż��� && goto :EOF
for /f "tokens=1 delims==" %%a in (%serialno%.list) do adb %d% shell "dumpsys deviceidle whitelist -%%a">>deviceidle.log && title ��������Ż���%%a��%t%
for /f "usebackq tokens=2 delims=:" %%a in (`find /c "Removed:" deviceidle.log`) do set num=%%a
echo �ѽ�%num% ��Ӧ���Ƴ��˵���Ż���������
del deviceidle.log
goto :EOF

:events
title ������¼���־������%t%
adb %d% logcat -d -b events>events.log
echo VVFGAA>>events.log
set /p fir=<events.log
if "%fir%"=="VVFGAA" set events=0
if not "%events%"=="0" (
  echo ----------am_proc_start---------->events.txt
  findstr "am_proc_start" events.log 1>>events.txt || echo ���棺δ����am_proc_start��־���޷�Ѹ�ٴ������⻽�ѵ�Ӧ�á�
  echo ----------am_restart_activity---------->>events.txt
  findstr "am_restart_activity" events.log 1>>events.txt || echo ���棺δ����am_restart_activity��־���޷�ʶ����汻�򿪡�
  echo ----------am_resume_activity---------->>events.txt
  findstr "am_resume_activity" events.log 1>>events.txt || echo ���棺δ����am_resume_activity��־���޷�ʶ����汻�򿪡�
  echo ----------screen_toggled---------->>events.txt
  findstr "screen_toggled" events.log 1>>events.txt || echo ���棺δ����screen_toggled��־���������ڿ�����ʱ���С�
  echo ----------am_new_intent---------->>events.txt
  findstr "am_new_intent" events.log 1>>events.txt || echo δ����am_new_intent��־���޷�ʶ����ҳ��
  echo ----------am_pause_activity---------->>events.txt
  findstr "am_pause_activity" events.log 1>>events.txt || echo δ����am_pause_activity��־���޷�ʶ����������ء�
  echo ----------am_switch_user---------->>events.txt
  findstr "am_switch_user" events.log 1>>events.txt || echo δ����am_switch_user��־�����������
  echo ----------notification_cancel_all---------->>events.txt
  findstr "notification_cancel_all" events.log 1>>events.txt || echo δ����notification_cancel_all��־���޷�ʶ��װ��ж��Ӧ���¼���
  echo ----------notification_panel_revealed---------->>events.txt
  findstr "notification_panel_revealed" events.log 1>>events.txt || echo δ����notification_panel_revealed��־�����в�����չ��֪ͨ��ʱ��ͣ��
  echo ----------notification_panel_hidden---------->>events.txt
  findstr "notification_panel_hidden" events.log 1>>events.txt || echo δ����notification_panel_hidden��־�����в���������֪ͨ����ָ���
  echo ----------device_idle---------->>events.txt
  findstr "device_idle:" events.log 1>>events.txt || echo δ����device_idle��־�����в����ڵ͵��ģʽ����ͣ��
  echo ----------device_idle_light---------->>events.txt
  findstr "device_idle_light:" events.log 1>>events.txt || echo δ����device_idle_light��־�����в����ڵ͵��ģʽ����ͣ��
  echo ----------notification_enqueue---------->>events.txt
  findstr "notification_enqueue:" events.log 1>>events.txt || echo δ����notification_enqueue��־��Ӱ����м��֪ͨ��
  echo ----------notification_canceled---------->>events.txt
  findstr "notification_canceled:" events.log 1>>events.txt || echo δ����notification_canceled��־��Ӱ����м��֪ͨ��
  echo ----------am_kill---------->>events.txt
  findstr "am_kill:" events.log 1>>events.txt || echo δ����am_kill��־��Ӱ����м����̡�

  if "%1"=="del" del events.txt
)
del events.log
goto :EOF

:end
if "%kill%"=="1" adb kill-server>nul 2>&1
exit
