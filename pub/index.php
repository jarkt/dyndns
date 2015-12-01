<?php

$availableDomains = array('ip.snap-agentur.de');
$domain = @$_GET['domain'];

if(!in_array($domain, $availableDomains)) {
	die('Unknown domain name!');
}

require 'DynDns.php';

$matches;
preg_match('#([a-z0-9]+)\\.([a-z0-9\\\\-]+\\.[a-z]+)#', $domain, $matches);
$domain = $matches[2];
$subdomain = $matches[1];

$dynDns = new DynDns($domain, $subdomain);
$loggedIn = $dynDns->login(@$_GET['user'], @$_GET['passwd']);
if(!$loggedIn) {
	die('Authentication failed!');
}

$id = $dynDns->getRecordId('A');
$success = $dynDns->setRecord($id, 'A', @$_GET['ipv4']);
if($success) {
	echo 'IPv4 record created!';
} else {
	echo 'IPv4 record not created!';
}

if(isset($_GET['ipv6'])) {
	$id = $dynDns->getRecordId('AAAA');
	$success = $dynDns->setRecord($id, 'AAAA', $_GET['ipv6']);
	if($success) {
		echo ' IPv6 record created!';
	} else {
		echo ' IPv6 record not created!';
	}
}

$dynDns->logout();
