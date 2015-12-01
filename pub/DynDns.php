<?php
require 'Domrobot.php';

class DynDns
{

	private $domrobot = null;
	private $domain = '';
	private $subdomain = '';


	public function __construct($domain, $subdomain) {
		$this->domrobot = new INWX\Domrobot('https://api.domrobot.com/xmlrpc/');
		$this->domrobot->setDebug(false);
		$this->domrobot->setLanguage('en');

		$this->domain = $domain;
		$this->subdomain = $subdomain;
	}

	public function login($username, $passwd) {
		$res = $this->domrobot->login($username, $passwd);
		return $res['code'] === 1000;
	}

	public function logout() {
		$this->domrobot->logout();
	}

	public function setRecord($id, $type, $ipv4) {
		$method = 'createRecord';
		$params = array(
			'name' => $this->subdomain,
			'type' => $type,
			'content' => $ipv4
		);
		if($id) {
			$method = 'updateRecord';
			$params['id'] = $id;
		} else {
			$params['domain'] = $this->domain;
		}
		$res = $this->domrobot->call('nameserver', $method, $params);
		return $res['code'] === 1000;
	}

	public function getRecordId($type) {
		$res = $this->domrobot->call('nameserver', 'info', array(
			'domain' => $this->domain
		));
		foreach($res['resData']['record'] as $rec) {
			if($rec['name'] !== "{$this->subdomain}.{$this->domain}") {
				continue;
			}
			if($rec['type'] !== $type) {
				continue;
			}
			return $rec['id'];
		}
		return null;
	}
}
