@echo off
rem 注意：本文件必须保存为 ANSI / GBK 编码 + CRLF 换行。
rem 若用 UTF-8 保存，cmd 会按 GBK 读成乱码，行被切断后直接闪退。
setlocal
title 安装报文解析工具到小工具目录
set "BAD=0"

set "SRC=%~dp0报文解析生成工具V1.7.html"
set "CIIS=D:\接口工具\CIIS-Tester\jetty-runner"
set "RMSCI=D:\接口工具\jetty-runner\jetty-runner"

echo ============================================================
echo  把「报文解析生成工具」装进两个接口小工具
echo  装完用 http://127.0.0.1:9988/msgparse/ 打开，才能读到返回
echo ============================================================
echo.

if not exist "%SRC%" goto :nosrc

echo 源文件：%SRC%
echo.

call :install "%CIIS%" CIIS
if errorlevel 1 set /a BAD+=1
call :install "%RMSCI%" RMSCI
if errorlevel 1 set /a BAD+=1

echo.
if "%BAD%"=="0" (
  echo ------------------------------------------------------------
  echo  安装完成，两个目录都已更新。
) else (
  echo ------------------------------------------------------------
  echo  有 %BAD% 个目录没装成功，原因见上面的 [失败] / [跳过] 行。
)
echo.
echo  使用步骤：
echo    1) 双击 9988.bat 启动小工具（CIIS 或 RMSCI，都占 9988）
echo    2) 浏览器打开 http://127.0.0.1:9988/msgparse/
echo    3) 字段报文页填好报文，点「发送到接口」；或到接口页点「取当前报文」
echo.
echo  注意：浏览器按站点隔离存储。以前双击 html 时的协议库不会自动
echo        带过来，第一次请用顶栏「恢复」读入备份 json。
echo ------------------------------------------------------------
echo.
pause
exit /b 0

:nosrc
echo [错误] 找不到源文件：
echo        %SRC%
echo.
echo        请把本 bat 和「报文解析生成工具V1.7.html」放在同一个文件夹。
echo.
pause
exit /b 1

:install
set "ROOT=%~1"
set "NAME=%~2"
set "DEST=%ROOT%\webapps\msgparse"
if not exist "%ROOT%" (
  echo [跳过] %NAME%：找不到目录 %ROOT%
  exit /b 1
)
if not exist "%ROOT%\webapps" (
  echo [跳过] %NAME%：%ROOT% 下没有 webapps，可能不是 jetty 目录
  exit /b 1
)
if not exist "%DEST%" mkdir "%DEST%"
copy /Y "%SRC%" "%DEST%\index.html" >nul 2>&1
if errorlevel 1 (
  echo [失败] %NAME%：复制被拒绝，多半是 9988.bat 还在跑
  echo        先关掉那个黑窗口，再双击本 bat
  exit /b 1
)
echo [OK]   %NAME%  -^>  %DEST%\index.html
exit /b 0
