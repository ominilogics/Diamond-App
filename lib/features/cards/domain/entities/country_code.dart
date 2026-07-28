class CountryCode {
  final String flag;
  final String name;
  final String dialCode;
  final String code;

  const CountryCode({
    required this.flag,
    required this.name,
    required this.dialCode,
    required this.code,
  });

  static const defaultCountry = CountryCode(
    flag: '🇺🇸',
    name: 'United States',
    dialCode: '+1',
    code: 'US',
  );

  static const List<CountryCode> allCountries = [
    CountryCode(flag: '🇦🇫', name: 'Afghanistan', dialCode: '+93', code: 'AF'),
    CountryCode(flag: '🇦🇽', name: 'Åland Islands', dialCode: '+358', code: 'AX'),
    CountryCode(flag: '🇦🇱', name: 'Albania', dialCode: '+355', code: 'AL'),
    CountryCode(flag: '🇩🇿', name: 'Algeria', dialCode: '+213', code: 'DZ'),
    CountryCode(flag: '🇦🇸', name: 'American Samoa', dialCode: '+1684', code: 'AS'),
    CountryCode(flag: '🇦🇩', name: 'Andorra', dialCode: '+376', code: 'AD'),
    CountryCode(flag: '🇦🇴', name: 'Angola', dialCode: '+244', code: 'AO'),
    CountryCode(flag: '🇦🇮', name: 'Anguilla', dialCode: '+1264', code: 'AI'),
    CountryCode(flag: '🇦🇬', name: 'Antigua & Barbuda', dialCode: '+1268', code: 'AG'),
    CountryCode(flag: '🇦🇷', name: 'Argentina', dialCode: '+54', code: 'AR'),
    CountryCode(flag: '🇦🇲', name: 'Armenia', dialCode: '+374', code: 'AM'),
    CountryCode(flag: '🇦🇼', name: 'Aruba', dialCode: '+297', code: 'AW'),
    CountryCode(flag: '🇦🇺', name: 'Australia', dialCode: '+61', code: 'AU'),
    CountryCode(flag: '🇦🇹', name: 'Austria', dialCode: '+43', code: 'AT'),
    CountryCode(flag: '🇦🇿', name: 'Azerbaijan', dialCode: '+994', code: 'AZ'),
    CountryCode(flag: '🇧🇸', name: 'Bahamas', dialCode: '+1242', code: 'BS'),
    CountryCode(flag: '🇧🇭', name: 'Bahrain', dialCode: '+973', code: 'BH'),
    CountryCode(flag: '🇧🇩', name: 'Bangladesh', dialCode: '+880', code: 'BD'),
    CountryCode(flag: '🇧🇧', name: 'Barbados', dialCode: '+1246', code: 'BB'),
    CountryCode(flag: '🇧🇾', name: 'Belarus', dialCode: '+375', code: 'BY'),
    CountryCode(flag: '🇧🇪', name: 'Belgium', dialCode: '+32', code: 'BE'),
    CountryCode(flag: '🇧🇿', name: 'Belize', dialCode: '+501', code: 'BZ'),
    CountryCode(flag: '🇧🇯', name: 'Benin', dialCode: '+229', code: 'BJ'),
    CountryCode(flag: '🇧🇲', name: 'Bermuda', dialCode: '+1441', code: 'BM'),
    CountryCode(flag: '🇧🇹', name: 'Bhutan', dialCode: '+975', code: 'BT'),
    CountryCode(flag: '🇧🇴', name: 'Bolivia', dialCode: '+591', code: 'BO'),
    CountryCode(flag: '🇧🇦', name: 'Bosnia & Herzegovina', dialCode: '+387', code: 'BA'),
    CountryCode(flag: '🇧🇼', name: 'Botswana', dialCode: '+267', code: 'BW'),
    CountryCode(flag: '🇧🇷', name: 'Brazil', dialCode: '+55', code: 'BR'),
    CountryCode(flag: '🇻🇬', name: 'British Virgin Islands', dialCode: '+1284', code: 'VG'),
    CountryCode(flag: '🇧🇳', name: 'Brunei', dialCode: '+673', code: 'BN'),
    CountryCode(flag: '🇧🇬', name: 'Bulgaria', dialCode: '+359', code: 'BG'),
    CountryCode(flag: '🇧🇫', name: 'Burkina Faso', dialCode: '+226', code: 'BF'),
    CountryCode(flag: '🇧🇮', name: 'Burundi', dialCode: '+257', code: 'BI'),
    CountryCode(flag: '🇰🇭', name: 'Cambodia', dialCode: '+855', code: 'KH'),
    CountryCode(flag: '🇨🇲', name: 'Cameroon', dialCode: '+237', code: 'CM'),
    CountryCode(flag: '🇨🇦', name: 'Canada', dialCode: '+1', code: 'CA'),
    CountryCode(flag: '🇨🇻', name: 'Cape Verde', dialCode: '+238', code: 'CV'),
    CountryCode(flag: '🇰🇾', name: 'Cayman Islands', dialCode: '+1345', code: 'KY'),
    CountryCode(flag: '🇨🇫', name: 'Central African Republic', dialCode: '+236', code: 'CF'),
    CountryCode(flag: '🇹🇩', name: 'Chad', dialCode: '+235', code: 'TD'),
    CountryCode(flag: '🇨🇱', name: 'Chile', dialCode: '+56', code: 'CL'),
    CountryCode(flag: '🇨🇳', name: 'China', dialCode: '+86', code: 'CN'),
    CountryCode(flag: '🇨🇽', name: 'Christmas Island', dialCode: '+61', code: 'CX'),
    CountryCode(flag: '🇨🇨', name: 'Cocos (Keeling) Islands', dialCode: '+61', code: 'CC'),
    CountryCode(flag: '🇨🇴', name: 'Colombia', dialCode: '+57', code: 'CO'),
    CountryCode(flag: '🇰🇲', name: 'Comoros', dialCode: '+269', code: 'KM'),
    CountryCode(flag: '🇨🇬', name: 'Congo - Brazzaville', dialCode: '+242', code: 'CG'),
    CountryCode(flag: '🇨🇩', name: 'Congo - Kinshasa', dialCode: '+243', code: 'CD'),
    CountryCode(flag: '🇨🇰', name: 'Cook Islands', dialCode: '+682', code: 'CK'),
    CountryCode(flag: '🇨🇷', name: 'Costa Rica', dialCode: '+506', code: 'CR'),
    CountryCode(flag: '🇨🇮', name: 'Côte d’Ivoire', dialCode: '+225', code: 'CI'),
    CountryCode(flag: '🇭🇷', name: 'Croatia', dialCode: '+385', code: 'HR'),
    CountryCode(flag: '🇨🇺', name: 'Cuba', dialCode: '+53', code: 'CU'),
    CountryCode(flag: '🇨🇼', name: 'Curaçao', dialCode: '+599', code: 'CW'),
    CountryCode(flag: '🇨🇾', name: 'Cyprus', dialCode: '+357', code: 'CY'),
    CountryCode(flag: '🇨🇿', name: 'Czech Republic', dialCode: '+420', code: 'CZ'),
    CountryCode(flag: '🇩🇰', name: 'Denmark', dialCode: '+45', code: 'DK'),
    CountryCode(flag: '🇩🇯', name: 'Djibouti', dialCode: '+253', code: 'DJ'),
    CountryCode(flag: '🇩🇲', name: 'Dominica', dialCode: '+1767', code: 'DM'),
    CountryCode(flag: '🇩🇴', name: 'Dominican Republic', dialCode: '+1809', code: 'DO'),
    CountryCode(flag: '🇪🇨', name: 'Ecuador', dialCode: '+593', code: 'EC'),
    CountryCode(flag: '🇪🇬', name: 'Egypt', dialCode: '+20', code: 'EG'),
    CountryCode(flag: '🇸🇻', name: 'El Salvador', dialCode: '+503', code: 'SV'),
    CountryCode(flag: '🇬🇶', name: 'Equatorial Guinea', dialCode: '+240', code: 'GQ'),
    CountryCode(flag: '🇪🇷', name: 'Eritrea', dialCode: '+291', code: 'ER'),
    CountryCode(flag: '🇪🇪', name: 'Estonia', dialCode: '+372', code: 'EE'),
    CountryCode(flag: '🇸🇿', name: 'Eswatini', dialCode: '+268', code: 'SZ'),
    CountryCode(flag: '🇪🇹', name: 'Ethiopia', dialCode: '+251', code: 'ET'),
    CountryCode(flag: '🇫🇰', name: 'Falkland Islands', dialCode: '+500', code: 'FK'),
    CountryCode(flag: '🇫🇴', name: 'Faroe Islands', dialCode: '+298', code: 'FO'),
    CountryCode(flag: '🇫🇯', name: 'Fiji', dialCode: '+679', code: 'FJ'),
    CountryCode(flag: '🇫🇮', name: 'Finland', dialCode: '+358', code: 'FI'),
    CountryCode(flag: '🇫🇷', name: 'France', dialCode: '+33', code: 'FR'),
    CountryCode(flag: '🇬🇫', name: 'French Guiana', dialCode: '+594', code: 'GF'),
    CountryCode(flag: '🇵🇫', name: 'French Polynesia', dialCode: '+689', code: 'PF'),
    CountryCode(flag: '🇬🇦', name: 'Gabon', dialCode: '+241', code: 'GA'),
    CountryCode(flag: '🇬🇲', name: 'Gambia', dialCode: '+220', code: 'GM'),
    CountryCode(flag: '🇬🇪', name: 'Georgia', dialCode: '+995', code: 'GE'),
    CountryCode(flag: '🇩🇪', name: 'Germany', dialCode: '+49', code: 'DE'),
    CountryCode(flag: '🇬🇭', name: 'Ghana', dialCode: '+233', code: 'GH'),
    CountryCode(flag: '🇬🇮', name: 'Gibraltar', dialCode: '+350', code: 'GI'),
    CountryCode(flag: '🇬🇷', name: 'Greece', dialCode: '+30', code: 'GR'),
    CountryCode(flag: '🇬🇱', name: 'Greenland', dialCode: '+299', code: 'GL'),
    CountryCode(flag: '🇬🇩', name: 'Grenada', dialCode: '+1473', code: 'GD'),
    CountryCode(flag: '🇬🇵', name: 'Guadeloupe', dialCode: '+590', code: 'GP'),
    CountryCode(flag: '🇬🇺', name: 'Guam', dialCode: '+1671', code: 'GU'),
    CountryCode(flag: '🇬🇹', name: 'Guatemala', dialCode: '+502', code: 'GT'),
    CountryCode(flag: '🇬🇬', name: 'Guernsey', dialCode: '+44', code: 'GG'),
    CountryCode(flag: '🇬🇳', name: 'Guinea', dialCode: '+224', code: 'GN'),
    CountryCode(flag: '🇬🇼', name: 'Guinea-Bissau', dialCode: '+245', code: 'GW'),
    CountryCode(flag: '🇬🇾', name: 'Guyana', dialCode: '+592', code: 'GY'),
    CountryCode(flag: '🇭🇹', name: 'Haiti', dialCode: '+509', code: 'HT'),
    CountryCode(flag: '🇭🇳', name: 'Honduras', dialCode: '+504', code: 'HN'),
    CountryCode(flag: '🇭🇰', name: 'Hong Kong', dialCode: '+852', code: 'HK'),
    CountryCode(flag: '🇭🇺', name: 'Hungary', dialCode: '+36', code: 'HU'),
    CountryCode(flag: '🇮🇸', name: 'Iceland', dialCode: '+354', code: 'IS'),
    CountryCode(flag: '🇮🇳', name: 'India', dialCode: '+91', code: 'IN'),
    CountryCode(flag: '🇮🇩', name: 'Indonesia', dialCode: '+62', code: 'ID'),
    CountryCode(flag: '🇮🇷', name: 'Iran', dialCode: '+98', code: 'IR'),
    CountryCode(flag: '🇮🇶', name: 'Iraq', dialCode: '+964', code: 'IQ'),
    CountryCode(flag: '🇮🇪', name: 'Ireland', dialCode: '+353', code: 'IE'),
    CountryCode(flag: '🇮🇲', name: 'Isle of Man', dialCode: '+44', code: 'IM'),
    CountryCode(flag: '🇮🇱', name: 'Israel', dialCode: '+972', code: 'IL'),
    CountryCode(flag: '🇮🇹', name: 'Italy', dialCode: '+39', code: 'IT'),
    CountryCode(flag: '🇯🇲', name: 'Jamaica', dialCode: '+1876', code: 'JM'),
    CountryCode(flag: '🇯🇵', name: 'Japan', dialCode: '+81', code: 'JP'),
    CountryCode(flag: '🇯🇪', name: 'Jersey', dialCode: '+44', code: 'JE'),
    CountryCode(flag: '🇯🇴', name: 'Jordan', dialCode: '+962', code: 'JO'),
    CountryCode(flag: '🇰🇿', name: 'Kazakhstan', dialCode: '+7', code: 'KZ'),
    CountryCode(flag: '🇰🇪', name: 'Kenya', dialCode: '+254', code: 'KE'),
    CountryCode(flag: '🇰🇮', name: 'Kiribati', dialCode: '+686', code: 'KI'),
    CountryCode(flag: '🇽🇰', name: 'Kosovo', dialCode: '+383', code: 'XK'),
    CountryCode(flag: '🇰🇼', name: 'Kuwait', dialCode: '+965', code: 'KW'),
    CountryCode(flag: '🇰🇬', name: 'Kyrgyzstan', dialCode: '+996', code: 'KG'),
    CountryCode(flag: '🇱🇦', name: 'Laos', dialCode: '+856', code: 'LA'),
    CountryCode(flag: '🇱🇻', name: 'Latvia', dialCode: '+371', code: 'LV'),
    CountryCode(flag: '🇱🇧', name: 'Lebanon', dialCode: '+961', code: 'LB'),
    CountryCode(flag: '🇱🇸', name: 'Lesotho', dialCode: '+266', code: 'LS'),
    CountryCode(flag: '🇱🇷', name: 'Liberia', dialCode: '+231', code: 'LR'),
    CountryCode(flag: '🇱🇾', name: 'Libya', dialCode: '+218', code: 'LY'),
    CountryCode(flag: '🇱🇮', name: 'Liechtenstein', dialCode: '+423', code: 'LI'),
    CountryCode(flag: '🇱🇹', name: 'Lithuania', dialCode: '+370', code: 'LT'),
    CountryCode(flag: '🇱🇺', name: 'Luxembourg', dialCode: '+352', code: 'LU'),
    CountryCode(flag: '🇲🇴', name: 'Macau', dialCode: '+853', code: 'MO'),
    CountryCode(flag: '🇲🇰', name: 'North Macedonia', dialCode: '+389', code: 'MK'),
    CountryCode(flag: '🇲🇬', name: 'Madagascar', dialCode: '+261', code: 'MG'),
    CountryCode(flag: '🇲🇼', name: 'Malawi', dialCode: '+265', code: 'MW'),
    CountryCode(flag: '🇲🇾', name: 'Malaysia', dialCode: '+60', code: 'MY'),
    CountryCode(flag: '🇲🇻', name: 'Maldives', dialCode: '+960', code: 'MV'),
    CountryCode(flag: '🇲🇱', name: 'Mali', dialCode: '+223', code: 'ML'),
    CountryCode(flag: '🇲🇹', name: 'Malta', dialCode: '+356', code: 'MT'),
    CountryCode(flag: '🇲🇭', name: 'Marshall Islands', dialCode: '+692', code: 'MH'),
    CountryCode(flag: '🇲🇶', name: 'Martinique', dialCode: '+596', code: 'MQ'),
    CountryCode(flag: '🇲🇷', name: 'Mauritania', dialCode: '+222', code: 'MR'),
    CountryCode(flag: '🇲🇺', name: 'Mauritius', dialCode: '+230', code: 'MU'),
    CountryCode(flag: '🇾🇹', name: 'Mayotte', dialCode: '+262', code: 'YT'),
    CountryCode(flag: '🇲🇽', name: 'Mexico', dialCode: '+52', code: 'MX'),
    CountryCode(flag: '🇫🇲', name: 'Micronesia', dialCode: '+691', code: 'FM'),
    CountryCode(flag: '🇲🇩', name: 'Moldova', dialCode: '+373', code: 'MD'),
    CountryCode(flag: '🇲🇨', name: 'Monaco', dialCode: '+377', code: 'MC'),
    CountryCode(flag: '🇲🇳', name: 'Mongolia', dialCode: '+976', code: 'MN'),
    CountryCode(flag: '🇲🇪', name: 'Montenegro', dialCode: '+382', code: 'ME'),
    CountryCode(flag: '🇲🇸', name: 'Montserrat', dialCode: '+1664', code: 'MS'),
    CountryCode(flag: '🇲🇦', name: 'Morocco', dialCode: '+212', code: 'MA'),
    CountryCode(flag: '🇲🇿', name: 'Mozambique', dialCode: '+258', code: 'MZ'),
    CountryCode(flag: '🇲🇲', name: 'Myanmar', dialCode: '+95', code: 'MM'),
    CountryCode(flag: '🇳🇦', name: 'Namibia', dialCode: '+264', code: 'NA'),
    CountryCode(flag: '🇳🇷', name: 'Nauru', dialCode: '+674', code: 'NR'),
    CountryCode(flag: '🇳🇵', name: 'Nepal', dialCode: '+977', code: 'NP'),
    CountryCode(flag: '🇳🇱', name: 'Netherlands', dialCode: '+31', code: 'NL'),
    CountryCode(flag: '🇳🇨', name: 'New Caledonia', dialCode: '+687', code: 'NC'),
    CountryCode(flag: '🇳🇿', name: 'New Zealand', dialCode: '+64', code: 'NZ'),
    CountryCode(flag: '🇳🇮', name: 'Nicaragua', dialCode: '+505', code: 'NI'),
    CountryCode(flag: '🇳🇪', name: 'Niger', dialCode: '+227', code: 'NE'),
    CountryCode(flag: '🇳🇬', name: 'Nigeria', dialCode: '+234', code: 'NG'),
    CountryCode(flag: '🇳🇺', name: 'Niue', dialCode: '+683', code: 'NU'),
    CountryCode(flag: '🇳🇫', name: 'Norfolk Island', dialCode: '+672', code: 'NF'),
    CountryCode(flag: '🇰🇵', name: 'North Korea', dialCode: '+850', code: 'KP'),
    CountryCode(flag: '🇲🇵', name: 'Northern Mariana Islands', dialCode: '+1670', code: 'MP'),
    CountryCode(flag: '🇳🇴', name: 'Norway', dialCode: '+47', code: 'NO'),
    CountryCode(flag: '🇴🇲', name: 'Oman', dialCode: '+968', code: 'OM'),
    CountryCode(flag: '🇵🇰', name: 'Pakistan', dialCode: '+92', code: 'PK'),
    CountryCode(flag: '🇵🇼', name: 'Palau', dialCode: '+680', code: 'PW'),
    CountryCode(flag: '🇵🇸', name: 'Palestine', dialCode: '+970', code: 'PS'),
    CountryCode(flag: '🇵🇦', name: 'Panama', dialCode: '+507', code: 'PA'),
    CountryCode(flag: '🇵🇬', name: 'Papua New Guinea', dialCode: '+675', code: 'PG'),
    CountryCode(flag: '🇵🇾', name: 'Paraguay', dialCode: '+595', code: 'PY'),
    CountryCode(flag: '🇵🇪', name: 'Peru', dialCode: '+51', code: 'PE'),
    CountryCode(flag: '🇵🇭', name: 'Philippines', dialCode: '+63', code: 'PH'),
    CountryCode(flag: '🇵🇱', name: 'Poland', dialCode: '+48', code: 'PL'),
    CountryCode(flag: '🇵🇹', name: 'Portugal', dialCode: '+351', code: 'PT'),
    CountryCode(flag: '🇵🇷', name: 'Puerto Rico', dialCode: '+1787', code: 'PR'),
    CountryCode(flag: '🇶🇦', name: 'Qatar', dialCode: '+974', code: 'QA'),
    CountryCode(flag: '🇷🇪', name: 'Réunion', dialCode: '+262', code: 'RE'),
    CountryCode(flag: '🇷🇴', name: 'Romania', dialCode: '+40', code: 'RO'),
    CountryCode(flag: '🇷🇺', name: 'Russia', dialCode: '+7', code: 'RU'),
    CountryCode(flag: '🇷🇼', name: 'Rwanda', dialCode: '+250', code: 'RW'),
    CountryCode(flag: '🇸🇭', name: 'St. Helena', dialCode: '+290', code: 'SH'),
    CountryCode(flag: '🇼🇸', name: 'Samoa', dialCode: '+685', code: 'WS'),
    CountryCode(flag: '🇸🇲', name: 'San Marino', dialCode: '+378', code: 'SM'),
    CountryCode(flag: '🇸🇹', name: 'São Tomé & Príncipe', dialCode: '+239', code: 'ST'),
    CountryCode(flag: '🇸🇦', name: 'Saudi Arabia', dialCode: '+966', code: 'SA'),
    CountryCode(flag: '🇸🇳', name: 'Senegal', dialCode: '+221', code: 'SN'),
    CountryCode(flag: '🇷🇸', name: 'Serbia', dialCode: '+381', code: 'RS'),
    CountryCode(flag: '🇸🇨', name: 'Seychelles', dialCode: '+248', code: 'SC'),
    CountryCode(flag: '🇸🇱', name: 'Sierra Leone', dialCode: '+232', code: 'SL'),
    CountryCode(flag: '🇸🇬', name: 'Singapore', dialCode: '+65', code: 'SG'),
    CountryCode(flag: '🇸🇽', name: 'Sint Maarten', dialCode: '+1721', code: 'SX'),
    CountryCode(flag: '🇸🇰', name: 'Slovakia', dialCode: '+421', code: 'SK'),
    CountryCode(flag: '🇸🇮', name: 'Slovenia', dialCode: '+386', code: 'SI'),
    CountryCode(flag: '🇸🇧', name: 'Solomon Islands', dialCode: '+677', code: 'SB'),
    CountryCode(flag: '🇸🇴', name: 'Somalia', dialCode: '+252', code: 'SO'),
    CountryCode(flag: '🇿🇦', name: 'South Africa', dialCode: '+27', code: 'ZA'),
    CountryCode(flag: '🇰🇷', name: 'South Korea', dialCode: '+82', code: 'KR'),
    CountryCode(flag: '🇸🇸', name: 'South Sudan', dialCode: '+211', code: 'SS'),
    CountryCode(flag: '🇪🇸', name: 'Spain', dialCode: '+34', code: 'ES'),
    CountryCode(flag: '🇱🇰', name: 'Sri Lanka', dialCode: '+94', code: 'LK'),
    CountryCode(flag: '🇧🇱', name: 'St. Barthélemy', dialCode: '+590', code: 'BL'),
    CountryCode(flag: '🇰🇳', name: 'St. Kitts & Nevis', dialCode: '+1869', code: 'KN'),
    CountryCode(flag: '🇱🇨', name: 'St. Lucia', dialCode: '+1758', code: 'LC'),
    CountryCode(flag: '🇲🇫', name: 'St. Martin', dialCode: '+590', code: 'MF'),
    CountryCode(flag: '🇵🇲', name: 'St. Pierre & Miquelon', dialCode: '+508', code: 'PM'),
    CountryCode(flag: '🇻🇨', name: 'St. Vincent & Grenadines', dialCode: '+1784', code: 'VC'),
    CountryCode(flag: '🇸🇩', name: 'Sudan', dialCode: '+249', code: 'SD'),
    CountryCode(flag: '🇸🇷', name: 'Suriname', dialCode: '+597', code: 'SR'),
    CountryCode(flag: '🇸🇯', name: 'Svalbard & Jan Mayen', dialCode: '+47', code: 'SJ'),
    CountryCode(flag: '🇸🇪', name: 'Sweden', dialCode: '+46', code: 'SE'),
    CountryCode(flag: '🇨🇭', name: 'Switzerland', dialCode: '+41', code: 'CH'),
    CountryCode(flag: '🇸🇾', name: 'Syria', dialCode: '+963', code: 'SY'),
    CountryCode(flag: '🇹🇼', name: 'Taiwan', dialCode: '+886', code: 'TW'),
    CountryCode(flag: '🇹🇯', name: 'Tajikistan', dialCode: '+992', code: 'TJ'),
    CountryCode(flag: '🇹🇿', name: 'Tanzania', dialCode: '+255', code: 'TZ'),
    CountryCode(flag: '🇹🇭', name: 'Thailand', dialCode: '+66', code: 'TH'),
    CountryCode(flag: '🇹🇱', name: 'Timor-Leste', dialCode: '+670', code: 'TL'),
    CountryCode(flag: '🇹🇬', name: 'Togo', dialCode: '+228', code: 'TG'),
    CountryCode(flag: '🇹🇰', name: 'Tokelau', dialCode: '+690', code: 'TK'),
    CountryCode(flag: '🇹🇴', name: 'Tonga', dialCode: '+676', code: 'TO'),
    CountryCode(flag: '🇹🇹', name: 'Trinidad & Tobago', dialCode: '+1868', code: 'TT'),
    CountryCode(flag: '🇹🇳', name: 'Tunisia', dialCode: '+216', code: 'TN'),
    CountryCode(flag: '🇹🇷', name: 'Turkey', dialCode: '+90', code: 'TR'),
    CountryCode(flag: '🇹🇲', name: 'Turkmenistan', dialCode: '+993', code: 'TM'),
    CountryCode(flag: '🇹🇨', name: 'Turks & Caicos Islands', dialCode: '+1649', code: 'TC'),
    CountryCode(flag: '🇹🇻', name: 'Tuvalu', dialCode: '+688', code: 'TV'),
    CountryCode(flag: '🇺🇬', name: 'Uganda', dialCode: '+256', code: 'UG'),
    CountryCode(flag: '🇺🇦', name: 'Ukraine', dialCode: '+380', code: 'UA'),
    CountryCode(flag: '🇦🇪', name: 'United Arab Emirates', dialCode: '+971', code: 'AE'),
    CountryCode(flag: '🇬🇧', name: 'United Kingdom', dialCode: '+44', code: 'GB'),
    CountryCode(flag: '🇺🇸', name: 'United States', dialCode: '+1', code: 'US'),
    CountryCode(flag: '🇺🇾', name: 'Uruguay', dialCode: '+598', code: 'UY'),
    CountryCode(flag: '🇺🇿', name: 'Uzbekistan', dialCode: '+998', code: 'UZ'),
    CountryCode(flag: '🇻🇺', name: 'Vanuatu', dialCode: '+678', code: 'VU'),
    CountryCode(flag: '🇻🇦', name: 'Vatican City', dialCode: '+39', code: 'VA'),
    CountryCode(flag: '🇻🇪', name: 'Venezuela', dialCode: '+58', code: 'VE'),
    CountryCode(flag: '🇻🇳', name: 'Vietnam', dialCode: '+84', code: 'VN'),
    CountryCode(flag: '🇻🇮', name: 'U.S. Virgin Islands', dialCode: '+1340', code: 'VI'),
    CountryCode(flag: '🇼🇫', name: 'Wallis & Futuna', dialCode: '+681', code: 'WF'),
    CountryCode(flag: '🇪🇭', name: 'Western Sahara', dialCode: '+212', code: 'EH'),
    CountryCode(flag: '🇾🇪', name: 'Yemen', dialCode: '+967', code: 'YE'),
    CountryCode(flag: '🇿🇲', name: 'Zambia', dialCode: '+260', code: 'ZM'),
    CountryCode(flag: '🇿🇼', name: 'Zimbabwe', dialCode: '+263', code: 'ZW'),
  ];

  /// Intelligently parses user input (e.g., "+447123456789", "034289123645", "+923001234567")
  /// Returns a record containing the matched [CountryCode] and the extracted clean national number.
  static ({CountryCode country, String cleanNumber}) detectFromInput(
    String input, {
    CountryCode currentFallback = defaultCountry,
  }) {
    final sanitized = input.trim();
    if (sanitized.isEmpty) {
      return (country: currentFallback, cleanNumber: '');
    }

    // 1. Check for local Pakistan national mobile format: "03..." (e.g. 034289123645)
    if (sanitized.startsWith('03')) {
      const pkCountry = CountryCode(
        flag: '🇵🇰',
        name: 'Pakistan',
        dialCode: '+92',
        code: 'PK',
      );
      final clean = sanitized.substring(1).replaceAll(RegExp(r'\D'), '');
      return (country: pkCountry, cleanNumber: clean);
    }

    // 2. Check for international "+" format (e.g. +447123456789 or +923001234567)
    if (sanitized.startsWith('+')) {
      final digitsOnly = sanitized.replaceAll(RegExp(r'[^\d+]'), '');

      // Sort countries by dial code length descending so longer dial codes match first
      final sortedCountries = List<CountryCode>.from(allCountries)
        ..sort((a, b) => b.dialCode.length.compareTo(a.dialCode.length));

      for (final country in sortedCountries) {
        if (digitsOnly.startsWith(country.dialCode)) {
          final clean = digitsOnly.substring(country.dialCode.length);
          return (country: country, cleanNumber: clean);
        }
      }
    }

    // Fallback: strip any non-digits
    final cleanDigits = sanitized.replaceAll(RegExp(r'\D'), '');
    return (country: currentFallback, cleanNumber: cleanDigits);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CountryCode &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          dialCode == other.dialCode;

  @override
  int get hashCode => code.hashCode ^ dialCode.hashCode;
}
