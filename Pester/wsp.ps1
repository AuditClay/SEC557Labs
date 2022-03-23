$uri = 'https://www.dataaccess.com/webservicesserver/NumberConversion.wso?wsdl'
$wsp=New-WebServiceProxy -Uri $uri
$wsp.NumberToDollars('1')