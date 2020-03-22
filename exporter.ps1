Import-Csv $args[0] |
ForEach-Object {
	$token = $_.DN
	$type = $token.SubString(0,2)
	switch($type){
		'OU' {
			$name = $token.SubString(3,$token.IndexOf(",")-3)
			$domain = $token.SubString($token.IndexOf(",")+1)
			New-ADOrganizationalUnit -Name $name -Path $domain -ProtectedFromAccidentalDeletion $False
		}
		'CN' {
			$name = $token.SubString(3,$token.IndexOf(",")-3)
      # 성과 이름을 띄어 쓴 경우로 가정, 순서는 한국어 성 - 이름
			$splits = $name -split ' '
			$surname = $splits[0]
			$given = $splits[1]
			$account = $name.Replace(" ",$null)
			$path = $token.SubString($token.IndexOf(",")+1)
      # 비밀번호는 내부 규칙에 따라 넣는다.
			$password = ConvertTo-SecureString -String (Password Text) -AsPlainText -Force
      # User Principal Name의 도메인은 적절하게 입력한다.
			New-ADUser -name $name -Path $path -GivenName $given -Surname  $surname -DisplayName $name -SamAccountName $account -UserPrincipalName $account"@github.com" -AccountPassword $password -Enabled $True
			$users.Add($account)
		}
	}
}

Add-AdGroupMember -Identity "Remote Desktop Users" -Members $users
