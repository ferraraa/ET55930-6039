#!/usr/bin/python3
import cgi, cgitb
cgitb.enable()
print("Content-type: text/html\n\n")
print("<html><head><title>Static CGI Test</title></head>")
print("<body><h1>Static HTML Test</h1></body>")
print("</html>")
