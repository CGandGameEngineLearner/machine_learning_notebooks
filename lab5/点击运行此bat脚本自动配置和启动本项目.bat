@echo off
setlocal

REM ���� Python �汾
set "pythonVersion=3.8.6"

REM ֻ���� pythonVersion �Ĵ����ֲ���
for /f "delims=." %%i in ("%pythonVersion%") do set "pythonVersionNumericString=%%i%%j%%k"

set "installerUrl=https://mirrors.huaweicloud.com/python/%pythonVersion%/python-%pythonVersion%-amd64.exe"
set "installerFile=python-%pythonVersion%-amd64.exe"

REM ���尲װ·��
set "userInstallPath=%LOCALAPPDATA%\Programs\Python\Python%pythonVersionNumericString%"

REM ����Ƿ��Ѿ���װ�˴˰汾�� Python
set "pythonInstalled=false"

for /f "tokens=*" %%i in ('reg query "HKCU\SOFTWARE\Python\PythonCore" 2^>nul') do (
    for /f "tokens=*" %%j in ('reg query "HKCU\SOFTWARE\Python\PythonCore\%%i" /v "DisplayName" 2^>nul') do (
        echo ��⵽�������� Python %%i
        if "%%i"=="%pythonVersion%" (
            set "pythonInstalled=true"
        )
    )
)

if "%pythonInstalled%"=="true" (
    echo Python %pythonVersion% �Ѱ�װ�ڼ�����ϡ�
) else (
    echo Python %pythonVersion% δ�ڼ�����ϰ�װ��׼���Զ���װPython %pythonVersion%
    echo ���ڼ����У������ĵȴ�������رմ˴��ڣ�

    REM ���� Python ��װ����
    echo �������� Python ��װ����...
    powershell -Command "Invoke-WebRequest -Uri %installerUrl% -OutFile %installerFile%"

    REM ��װ Python
    echo ���ڰ�װ Python�����Ժ�...
    start /wait "" "%installerFile%" /quiet InstallAllUsers=0 PrependPath=1 DefaultJustForMeTargetDir="%userInstallPath%"

    REM �� Python ��ӵ�ϵͳ����������
    setx PATH "%PATH%;%userInstallPath%"

    REM �� Python ��ӵ�ע���
    set "pythonPath=%userInstallPath%\python.exe"
    reg add "HKCU\Software\Python\PythonCore\%pythonVersion%" /ve /d "%pythonVersion%" /f
    reg add "HKCU\Software\Python\PythonCore\%pythonVersion%" /v "InstallPath" /d "%userInstallPath%" /f
    reg add "HKCU\Software\Python\PythonCore\%pythonVersion%" /v "ExecutablePath" /d "%pythonPath%" /f

    REM ɾ����װ����
    echo Python ��װ��ɣ�ɾ����װ����...
    del "%installerFile%"

    echo Python %pythonVersion% �Ѱ�װ�ɹ�
)

REM �������⻷��
%userInstallPath%\python.exe -m venv venv

REM �������⻷��
call venv\Scripts\activate.bat

call run.bat

REM ���н����������˳�
pause