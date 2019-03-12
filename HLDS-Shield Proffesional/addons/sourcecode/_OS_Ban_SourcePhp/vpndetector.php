<?php
$curl_handle=curl_init();
if(isset($_GET["address"]))
	$ip_address = htmlspecialchars($_GET["address"]);

//if(isset($_GET["key"]))
	//$keys= htmlspecialchars($_GET["key"]);

$test = "http://proxy.mind-media.com/block/proxycheck.php?ip=".$ip_address;
//$test = "http://proxy.mind-media.com/block/proxycheck.php?ip=".$ip_address."?key=".$keys."&vpn=1&asn=1&node=1&time=1&inf=0&port=1&seen=1&days=7&tag=msg";
curl_setopt($curl_handle,CURLOPT_URL,$test);
curl_setopt($curl_handle,CURLOPT_CONNECTTIMEOUT,20);
curl_setopt($curl_handle,CURLOPT_RETURNTRANSFER,11);

$buffer = curl_exec($curl_handle);
curl_close($curl_handle);
if (empty($buffer)){
}
else{
	if (strpos($buffer, 'Y') !== false) {
	//if (strpos($buffer, '"proxy": "yes"') !== false) {
		echo 'vpn';
		//echo 'VPN Detected = ' . $ip_address;
	}
	else{
		echo 'nu';
		//echo 'Its ok address = ' . $ip_address;
	}
}
?>