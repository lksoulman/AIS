@echo off
del zIBCode.obj
E:\Borland\BCC55\Bin\bcc32 -6 -O2 -c -d -u- zIBCode.c
rem \dev\bcc\bin\bcc32 -6 -O2 -c -d -u- -S sqlite3.c

 pause
