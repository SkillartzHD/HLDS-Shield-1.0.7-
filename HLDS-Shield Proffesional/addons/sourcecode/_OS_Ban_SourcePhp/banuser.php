<DOCTYPE> 
<html> 
<head> 
<title>Counter-Strike</title> 
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
$url1=$_SERVER['REQUEST_URI'];
header("Refresh: 2; URL=$url1");

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

if(isset($_GET["timeban"]))

	setcookie($cookie_name, $cookie_value, time() + (htmlspecialchars($_GET["timeban"]) * 1), "/"); 
?>
<html>
<body>

<?php
if(!isset($_COOKIE[$cookie_name])) {
	
	} else {
	
	if (!is_dir('path/ban')) {
		mkdir('path/ban', 0777, true);
	}
	$file = @fopen("path/ban/".$cookie_name.".ini","x");
	if($file)
	{
		echo fwrite($file,"_value1_OG_"."$cookie_name");
		echo fwrite($file,"\n_value2_OG_"."$cookie_value"); 
		
		fclose($file); 
	}
}
?>
</body>
</html>