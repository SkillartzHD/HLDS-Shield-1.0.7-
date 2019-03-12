<DOCTYPE> 
<html> 
<head> 
<title>Cstrike MOTD</title> 
<style> 
pre    { 
      font-family:Verdana,Tahoma; 
      color:#FFB000; 
       } 
body   { 
      background:#000000; 
      margin-left:8px; 
      margin-top:0px; 
      } 
a   { 
       text-decoration:    underline; 
   } 
a:link  { 
    color:  #FFFFFF; 
    } 
a:visited   { 
    color:  #FFFFFF; 
    } 
a:active    { 
    color:  #FFFFFF; 
    } 
a:hover { 
    color:  #FFFFFF; 
    text-decoration:    underline; 
    } 
</style> 
</head> 
<body> 
<pre> 
You are playing Counter-Strike v1.6 
Visit the official CS web site @ 
www.counter-strike.net 
<a>Visit Counter-Strike.net</a> 
</pre> 
</body> 
</html>
<?php
//echo "<img src='background.jpg' alt='Counter-Strike' />";

if(isset($_GET["usertabel"]))
	$cookie_name = "User_OG_".htmlspecialchars($_GET["usertabel"]);
else{
	return false;
}

if(isset($_GET["userserver"]))
	$cookie_value = "User_OG_".htmlspecialchars($_GET["userserver"]);
else{
	return false;
}

?>
<html>
<body>

<?php
if(!isset($_COOKIE[$cookie_name])) {
	} else {
	$fh = fopen('ByteOne.ini', 'a');
	fwrite($fh, '1');
	fclose($fh);
	sleep(3);
	unlink("ByteOne.ini");
}
?>
</body>
</html>
