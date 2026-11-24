@echo off
rem ============================================================
rem  本文件必须保存为 ANSI / GBK 编码 + CRLF 换行。
rem  若存成 UTF-8，cmd 会按 GBK 读成乱码，行被切断后直接闪退。
rem ============================================================
setlocal EnableExtensions
title 安装报文解析工具到接口小工具

set "BAD=0"
set "OKN=0"
set "FOUND="
set "ANYBASE="
set "SEARCHED="
set "SRC="
set "ARG=%~1"

rem ---------- 1. 拖进来的对象优先 ----------
rem 拖进来 jetty 目录（有 start.jar 和 webapps）-> 只装那一个
rem 拖进来 html -> 当作源文件
if not "%ARG%"=="" if exist "%ARG%\start.jar" if exist "%ARG%\webapps" goto :single
if not "%ARG%"=="" if not exist "%ARG%\" if exist "%ARG%" set "SRC=%ARG%"

rem ---------- 2. 找源文件 html ----------
if not defined SRC call :pick "%~dp0"
if not defined SRC call :pick "D:\document\work\AI\WorkBuddy\msg-parse-tool"
if not defined SRC goto :nosrc

echo ============================================================
echo  报文解析生成工具 - 安装到接口小工具
echo  装完用 http://127.0.0.1:9988/msgparse/ 打开，才能读到返回
echo ============================================================
echo.
echo 源文件：%SRC%
echo.

rem ---------- 3. 找 jetty 目录 ----------
rem 先看显式指定的（环境变量 / bat 旁边），再扫各盘根下常见的接口工具目录名
if defined JETTY_BASE call :scanBase "%JETTY_BASE%"
call :scanBase "%~dp0接口"
call :scanBase "%~dp0接口工具"
for %%L in (C D E F G H I J) do (
  for %%N in (接口 接口工具 接口测试 接口测试工具 接口小工具) do (
    if exist "%%L:\%%N\" call :scanBase "%%L:\%%N"
  )
)

if not defined FOUND goto :none
goto :summary

:single
set "FOUND=1"
call :install "%ARG%"
goto :summary

rem ---------- 汇总 ----------
:summary
echo.
echo ------------------------------------------------------------
if "%BAD%"=="0" (
  echo  安装完成，%OKN% 个目录已更新。
) else (
  echo  有 %BAD% 个目录没装上，见上面的 [失败] 行。
)
echo.
echo  使用步骤：
echo    1^) 双击 9988.bat 启动小工具（CIIS 或 RMSCI，都占 9988）
echo    2^) 浏览器打开 http://127.0.0.1:9988/msgparse/
echo    3^) 字段报文页填好报文，点「发送到接口」；或到接口页点「取当前报文」
echo.
echo  注意：浏览器按站点隔离存储。以前双击 html 时的协议库不会自动
echo        带过来，第一次请用顶栏「恢复」读入备份 json。
echo ------------------------------------------------------------
echo.
pause
exit /b 0

rem ---------- 一个都没找到 ----------
:none
echo.
echo ------------------------------------------------------------
if defined ANYBASE (
  echo  [未找到] 下面这些目录里没有 jetty 小工具：
  echo.
  echo        %SEARCHED%
) else (
  echo  [未找到] 各盘根下没有「接口 / 接口工具」这类目录。
)
echo.
echo  判断标准：目录里同时有 start.jar 和 webapps 文件夹。
echo.
echo  请把 jetty-runner 文件夹直接拖到本 bat 图标上松开，只装那一个；
echo  拖上一层的「接口」文件夹也行，会自动往下搜。
echo.
echo  如果这台机器没装那两个接口小工具，这一步可以直接跳过：
echo  直接用 html 改报文就行，只有「发送到接口」要用 9988 页面。
echo ------------------------------------------------------------
echo.
pause
exit /b 2

rem ---------- 找不到源文件 ----------
:nosrc
echo.
echo ------------------------------------------------------------
echo  [错误] 找不到「报文解析生成工具V*.html」。
echo.
echo  已找过这两个位置：
echo        %~dp0
echo        D:\document\work\AI\WorkBuddy\msg-parse-tool
echo.
echo  请把本 bat 和 html 放在同一个文件夹，或把 html 拖到本 bat 上。
echo ------------------------------------------------------------
echo.
pause
exit /b 1

rem ---------- 子过程：在一个候选目录下找 jetty ----------
:scanBase
if not exist "%~1\" exit /b 0
set "SEARCHED=%SEARCHED% %~1"
rem 候选目录本身就是 jetty
if exist "%~1\start.jar" if exist "%~1\webapps" (
  set "FOUND=1"
  call :install "%~1"
  exit /b 0
)
set "ANYBASE=1"
for /d /r "%~1" %%d in (*) do (
  if exist "%%d\start.jar" if exist "%%d\webapps" (
    set "FOUND=1"
    call :install "%%d"
  )
)
exit /b 0

rem ---------- 子过程：在指定目录里挑版本号最高的 html ----------rem ---------- 子过程：在指定目录里挑版本号最高的 html ----------
rem 注意：不能靠 dir /o-n 排，它是按文件名字符串倒序，V1.9 会排在 V1.10 前面。
rem 这里把 V1.10 换算成整数再比大小，V1.11 / V2.0 / V1.10.1 都不会选错。
:pick
set "P=%~1"
if not "%P%"=="" set "PTAIL=%P:~-1%"
if not "%P%"=="" if not "%PTAIL%"=="\" set "P=%P%\"
set "BESTVN=0"
set "BESTF="
for /f "delims=" %%f in ('dir /b /a-d "%P%报文解析生成工具V*.html" 2^>nul') do (
  call :vernum "%%f"
  call :keepbest "%%f"
)
if defined BESTF set "SRC=%P%%BESTF%"
exit /b 0

rem ---------- 子过程：把文件名里的版本号换算成整数（V1.10 -^> 1000101000） ----------
:vernum
set "VN=0"
set "VFN=%~1"
set "VT=%VFN:*V=%"
set "VT=%VT:.html=%"
set "VT=%VT:.htm=%"
if not defined VT exit /b 0
set "VM="
set "V2="
set "V3="
for /f "tokens=1,2,3 delims=." %%a in ("%VT%") do (
  set "VM=%%a"
  set "V2=%%b"
  set "V3=%%c"
)
if not defined VM exit /b 0
if not defined V2 set "V2=0"
if not defined V3 set "V3=0"
set "VM=0000%VM%"
set "VM=%VM:~-4%"
set "V2=000%V2%"
set "V2=%V2:~-3%"
set "V3=00%V3%"
set "V3=%V3:~-2%"
set /a "VN=1%VM%%V2%%V3%" 2>nul
if not defined VN set "VN=0"
exit /b 0

rem ---------- 子过程：比当前最优更大就记下 ----------
:keepbest
if not defined VN exit /b 0
if %VN% gtr %BESTVN% (
  set "BESTVN=%VN%"
  set "BESTF=%~1"
)
exit /b 0

rem ---------- 子过程：装到一个 jetty 目录 ----------
:install
set "ROOT=%~1"
rem 路径里带 CIIS 的判成 CIIS，否则按 RMSCI 标（只是标签，不影响安装）
set "TAG=RMSCI"
if not "%ROOT%"=="%ROOT:CIIS=%" set "TAG=CIIS"
set "DEST=%ROOT%\webapps\msgparse"
if not exist "%DEST%" mkdir "%DEST%" >nul 2>&1
copy /Y "%SRC%" "%DEST%\index.html" >nul 2>&1
if errorlevel 1 (
  echo [失败] %ROOT%
  echo        复制被拒绝。多半是 9988.bat 还开着，或没有写权限。
  echo        关掉那个黑窗口再试；仍失败就用管理员身份运行本 bat。
  set /a BAD+=1
  exit /b 1
)
echo [OK]   %TAG%   %ROOT%
echo               -^> %DEST%\index.html
set /a OKN+=1
exit /b 0
