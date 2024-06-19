@echo OFF
SETLOCAL EnableDelayedExpansion

:: Define the download path relative to the batch file location
SET downloadPath=%~dp0

echo Verbose logging is enabled.
echo The batch file is located at: %downloadPath%

echo Checking for Ollama installation...
:: Check for Ollama installation and install if not present
ollama --version >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
    echo Ollama is not installed. Preparing to install Ollama...
    echo Downloading OllamaSetup.exe to %downloadPath%
    start /wait powershell.exe -Command "Invoke-WebRequest -Uri 'https://ollama.com/download/OllamaSetup.exe' -OutFile '%downloadPath%OllamaSetup.exe'"
    echo Download complete. Running OllamaSetup.exe from %downloadPath%OllamaSetup.exe
    start /wait "" "%downloadPath%OllamaSetup.exe" & echo Ollama installed successfully.
) ELSE (
    echo Ollama is already installed.
)

echo Checking if Ollama is running...
:: Check if Ollama is running and start if not
tasklist /FI "IMAGENAME eq ollama.exe" 2>NUL | find /I "ollama.exe">NUL
IF %ERRORLEVEL% NEQ 0 (
    echo Ollama is not running. Starting Ollama in the background...
    start /B ollama start
    :waitForOllama
    tasklist /FI "IMAGENAME eq ollama.exe" 2>NUL | find /I "ollama.exe">NUL
    IF %ERRORLEVEL% NEQ 0 (
        echo Waiting for Ollama to start...
        timeout /t 5 >nul
        goto :waitForOllama
    ) ELSE (
        echo Ollama is running in the background.
    )
) ELSE (
    echo Ollama is already running.
)

echo Checking for Llama3 image...
:: Check for Llama3 image and pull if not present
FOR /F "tokens=*" %%i IN ('ollama list ^| find "llama3"') DO SET llama3Image=%%i
IF "!llama3Image!"=="" (
    echo Llama3 image is not present. Pulling Llama3 image...
    ollama pull llama3:latest
    echo Llama3 image pulled successfully.
	echo Running llama3
	ollama run llama3:latest
) ELSE (
    echo Llama3 image is already present.
	echo Running llama3
	ollama run llama3:latest
)

:: End of script
echo Batch process complete.
ENDLOCAL
pause
cmd /k
