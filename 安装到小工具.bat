@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
set SRC=%~dp0报文解析生成工具V1.7.html

echo ============================================================
echo  把「报文解析生成工具」安装到两个小工具的 webapps 目录
echo  安装后就能用 http://127.0.0.1:9988/msgparse/ 打开，
echo  与 /tester/api 同源，发报文才能读到返回。
echo ============================================================
echo.

if not exist "%SRC%" (
  echo [错误] 找不到 "%SRC%"
  echo        请把本 bat 和「报文解析生成工具V1.7.html」放在同一个文件夹里。
  echo.
  pause
  exit /b 1
)

call :inst "D:\接口工具\CIIS-Tester\jetty-runner" "CIIS"
call :inst "D:\接口工具\jetty-runner\jetty-runner" "RMSCI"

echo.
echo ------------------------------------------------------------
echo 安装完成。之后的使用步骤：
echo   1) 双击 9988.bat 启动小工具（CIIS 或 RMSCI，二选一）
echo   2) 浏览器打开  http://127.0.0.1:9988/msgparse/
echo   3) 在「字段报文」页填好报文，点「发送到接口 -^>」；
echo      或直接在「接口调用」页点「^<- 取当前报文」
echo.
echo 注意：浏览器按站点隔离存储。以前双击 html（file://）时的协议库
echo       不会自动带过来，第一次请用顶栏「恢复」读入备份 json，
echo       或用「导入协议」把导出的 json 导进来。
echo ------------------------------------------------------------
echo.
pause
exit /b 0

:inst
if not exist "%~1" (
  echo [跳过] 找不到目录  %~1
  goto :eof
)
if not exist "%~1\webapps" (
  echo [跳过] %~1 下没有 webapps 目录，可能不是 jetty 目录
  goto :eof
)
if not exist "%~1\webapps\msgparse" mkdir "%~1\webapps\msgparse"
copy /Y "%SRC%" "%~1\webapps\msgparse\index.html" >nul 2>&1
if errorlevel 1 (
  echo [失败] %~2 复制失败：多半是 9988.bat 还在运行，先关掉那个黑窗口再试
) else (
  echo [OK]   %~2  -^>  %~1\webapps\msgparse\index.html
)
goto :eof
