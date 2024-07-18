/***********************************************************************************************************************************
* Script      : 99.Lookup -  Setup - Country.sql                                                                                   *
* Created By  : Cedric Dube                                                                                                      *
* Created On  : 2021-09-06                                                                                                         *
* Execute On  : As required.                                                                                                       *
* Execute As  : N/A                                                                                                                *
* Execution   : Entire script.                                                                                                     *
* Version     : 1.0                                                                                                                *
***********************************************************************************************************************************/
USE [dbSurge]
GO
IF OBJECT_ID('TempDB..#Country') IS NOT NULL
  DROP TABLE #Country;
CREATE TABLE #Country (
  [CountryCode]      [CHAR](2)       NOT NULL,
  [Alpha2ISOCode]    [CHAR](2)           NULL,
  [Alpha3ISOCode]    VARCHAR(3)           NULL,
  [NumericISOCode]   VARCHAR(3)           NULL,
  [ShortNameEnglish] [NVARCHAR](256)     NULL
);

INSERT INTO #Country ([CountryCode], [Alpha2ISOCode], [Alpha3ISOCode], [NumericISOCode], [ShortNameEnglish])
VALUES ('--', '--', '---', '---', N'Unknown'                                               ),
       ('AF', 'AF', 'AFG', '004', N'Afghanistan'                                               ),
       ('AX', 'AX', 'ALA', '248', N'�land Islands'                                             ),
       ('AL', 'AL', 'ALB', '008', N'Albania'                                                   ),
       ('DZ', 'DZ', 'DZA', '012', N'Algeria'                                                   ),
       ('AS', 'AS', 'ASM', '016', N'American Samoa'                                            ),
       ('AD', 'AD', 'AND', '020', N'Andorra'                                                   ),
       ('AO', 'AO', 'AGO', '024', N'Angola'                                                    ),
       ('AI', 'AI', 'AIA', '660', N'Anguilla'                                                  ),
       ('AQ', 'AQ', 'ATA', '010', N'Antarctica'                                                ),
       ('AG', 'AG', 'ATG', '028', N'Antigua and Barbuda'                                       ),
       ('AR', 'AR', 'ARG', '032', N'Argentina'                                                 ),
       ('AM', 'AM', 'ARM', '051', N'Armenia'                                                   ),
       ('AW', 'AW', 'ABW', '533', N'Aruba'                                                     ),
       ('AU', 'AU', 'AUS', '036', N'Australia'                                                 ),
       ('AT', 'AT', 'AUT', '040', N'Austria'                                                   ),
       ('AZ', 'AZ', 'AZE', '031', N'Azerbaijan'                                                ),
       ('BS', 'BS', 'BHS', '044', N'Bahamas (the)'                                             ),
       ('BH', 'BH', 'BHR', '048', N'Bahrain'                                                   ),
       ('BD', 'BD', 'BGD', '050', N'Bangladesh'                                                ),
       ('BB', 'BB', 'BRB', '052', N'Barbados'                                                  ),
       ('BY', 'BY', 'BLR', '112', N'Belarus'                                                   ),
       ('BE', 'BE', 'BEL', '056', N'Belgium'                                                   ),
       ('BZ', 'BZ', 'BLZ', '084', N'Belize'                                                    ),
       ('BJ', 'BJ', 'BEN', '204', N'Benin'                                                     ),
       ('BM', 'BM', 'BMU', '060', N'Bermuda'                                                   ),
       ('BT', 'BT', 'BTN', '064', N'Bhutan'                                                    ),
       ('BO', 'BO', 'BOL', '068', N'Bolivia (Plurinational State of)'                          ),
       ('BQ', 'BQ', 'BES', '535', N'Bonaire, Sint Eustatius and Saba'                          ),
       ('BA', 'BA', 'BIH', '070', N'Bosnia and Herzegovina'                                    ),
       ('BW', 'BW', 'BWA', '072', N'Botswana'                                                  ),
       ('BV', 'BV', 'BVT', '074', N'Bouvet Island'                                             ),
       ('BR', 'BR', 'BRA', '076', N'Brazil'                                                    ),
       ('IO', 'IO', 'IOT', '086', N'British Indian Ocean Territory (the)'                      ),
       ('BN', 'BN', 'BRN', '096', N'Brunei Darussalam'                                         ),
       ('BG', 'BG', 'BGR', '100', N'Bulgaria'                                                  ),
       ('BF', 'BF', 'BFA', '854', N'Burkina Faso'                                              ),
       ('BI', 'BI', 'BDI', '108', N'Burundi'                                                   ),
       ('CV', 'CV', 'CPV', '132', N'Cabo Verde'                                                ),
       ('KH', 'KH', 'KHM', '116', N'Cambodia'                                                  ),
       ('CM', 'CM', 'CMR', '120', N'Cameroon'                                                  ),
       ('CA', 'CA', 'CAN', '124', N'Canada'                                                    ),
       ('KY', 'KY', 'CYM', '136', N'Cayman Islands (the)'                                      ),
       ('CF', 'CF', 'CAF', '140', N'Central African Republic (the)'                            ),
       ('TD', 'TD', 'TCD', '148', N'Chad'                                                      ),
       ('CL', 'CL', 'CHL', '152', N'Chile'                                                     ),
       ('CN', 'CN', 'CHN', '156', N'China'                                                     ),
       ('CX', 'CX', 'CXR', '162', N'Christmas Island'                                          ),
       ('CC', 'CC', 'CCK', '166', N'Cocos (Keeling) Islands (the)'                             ),
       ('CO', 'CO', 'COL', '170', N'Colombia'                                                  ),
       ('KM', 'KM', 'COM', '174', N'Comoros (the)'                                             ),
       ('CD', 'CD', 'COD', '180', N'Congo (the Democratic Republic of the)'                    ),
       ('CG', 'CG', 'COG', '178', N'Congo (the)'                                               ),
       ('CK', 'CK', 'COK', '184', N'Cook Islands (the)'                                        ),
       ('CR', 'CR', 'CRI', '188', N'Costa Rica'                                                ),
       ('CI', 'CI', 'CIV', '384', N'C�te d''Ivoire'                                            ),
       ('HR', 'HR', 'HRV', '191', N'Croatia'                                                   ),
       ('CU', 'CU', 'CUB', '192', N'Cuba'                                                      ),
       ('CW', 'CW', 'CUW', '531', N'Cura�ao'                                                   ),
       ('CY', 'CY', 'CYP', '196', N'Cyprus'                                                    ),
       ('CZ', 'CZ', 'CZE', '203', N'Czechia'                                                   ),
       ('DK', 'DK', 'DNK', '208', N'Denmark'                                                   ),
       ('DJ', 'DJ', 'DJI', '262', N'Djibouti'                                                  ),
       ('DM', 'DM', 'DMA', '212', N'Dominica'                                                  ),
       ('DO', 'DO', 'DOM', '214', N'Dominican Republic (the)'                                  ),
       ('EC', 'EC', 'ECU', '218', N'Ecuador'                                                   ),
       ('EG', 'EG', 'EGY', '818', N'Egypt'                                                     ),
       ('SV', 'SV', 'SLV', '222', N'El Salvador'                                               ),
       ('GQ', 'GQ', 'GNQ', '226', N'Equatorial Guinea'                                         ),
       ('ER', 'ER', 'ERI', '232', N'Eritrea'                                                   ),
       ('EE', 'EE', 'EST', '233', N'Estonia'                                                   ),
       ('SZ', 'SZ', 'SWZ', '748', N'Eswatini'                                                  ),
       ('ET', 'ET', 'ETH', '231', N'Ethiopia'                                                  ),
       ('FK', 'FK', 'FLK', '238', N'Falkland Islands (the) [Malvinas]'                         ),
       ('FO', 'FO', 'FRO', '234', N'Faroe Islands (the)'                                       ),
       ('FJ', 'FJ', 'FJI', '242', N'Fiji'                                                      ),
       ('FI', 'FI', 'FIN', '246', N'Finland'                                                   ),
       ('FR', 'FR', 'FRA', '250', N'France'                                                    ),
       ('GF', 'GF', 'GUF', '254', N'French Guiana'                                             ),
       ('PF', 'PF', 'PYF', '258', N'French Polynesia'                                          ),
       ('TF', 'TF', 'ATF', '260', N'French Southern Territories (the)'                         ),
       ('GA', 'GA', 'GAB', '266', N'Gabon'                                                     ),
       ('GM', 'GM', 'GMB', '270', N'Gambia (the)'                                              ),
       ('GE', 'GE', 'GEO', '268', N'Georgia'                                                   ),
       ('DE', 'DE', 'DEU', '276', N'Germany'                                                   ),
       ('GH', 'GH', 'GHA', '288', N'Ghana'                                                     ),
       ('GI', 'GI', 'GIB', '292', N'Gibraltar'                                                 ),
       ('GR', 'GR', 'GRC', '300', N'Greece'                                                    ),
       ('GL', 'GL', 'GRL', '304', N'Greenland'                                                 ),
       ('GD', 'GD', 'GRD', '308', N'Grenada'                                                   ),
       ('GP', 'GP', 'GLP', '312', N'Guadeloupe'                                                ),
       ('GU', 'GU', 'GUM', '316', N'Guam'                                                      ),
       ('GT', 'GT', 'GTM', '320', N'Guatemala'                                                 ),
       ('GG', 'GG', 'GGY', '831', N'Guernsey'                                                  ),
       ('GN', 'GN', 'GIN', '324', N'Guinea'                                                    ),
       ('GW', 'GW', 'GNB', '624', N'Guinea-Bissau'                                             ),
       ('GY', 'GY', 'GUY', '328', N'Guyana'                                                    ),
       ('HT', 'HT', 'HTI', '332', N'Haiti'                                                     ),
       ('HM', 'HM', 'HMD', '334', N'Heard Island and McDonald Islands'                         ),
       ('VA', 'VA', 'VAT', '336', N'Holy See (the)'                                            ),
       ('HN', 'HN', 'HND', '340', N'Honduras'                                                  ),
       ('HK', 'HK', 'HKG', '344', N'Hong Kong'                                                 ),
       ('HU', 'HU', 'HUN', '348', N'Hungary'                                                   ),
       ('IS', 'IS', 'ISL', '352', N'Iceland'                                                   ),
       ('IN', 'IN', 'IND', '356', N'India'                                                     ),
       ('ID', 'ID', 'IDN', '360', N'Indonesia'                                                 ),
       ('IR', 'IR', 'IRN', '364', N'Iran (Islamic Republic of)'                                ),
       ('IQ', 'IQ', 'IRQ', '368', N'Iraq'                                                      ),
       ('IE', 'IE', 'IRL', '372', N'Ireland'                                                   ),
       ('IM', 'IM', 'IMN', '833', N'Isle of Man'                                               ),
       ('IL', 'IL', 'ISR', '376', N'Israel'                                                    ),
       ('IT', 'IT', 'ITA', '380', N'Italy'                                                     ),
       ('JM', 'JM', 'JAM', '388', N'Jamaica'                                                   ),
       ('JP', 'JP', 'JPN', '392', N'Japan'                                                     ),
       ('JE', 'JE', 'JEY', '832', N'Jersey'                                                    ),
       ('JO', 'JO', 'JOR', '400', N'Jordan'                                                    ),
       ('KZ', 'KZ', 'KAZ', '398', N'Kazakhstan'                                                ),
       ('KE', 'KE', 'KEN', '404', N'Kenya'                                                     ),
       ('KI', 'KI', 'KIR', '296', N'Kiribati'                                                  ),
       ('KP', 'KP', 'PRK', '408', N'Korea (the Democratic People''s Republic of)'              ),
       ('KR', 'KR', 'KOR', '410', N'Korea (the Republic of)'                                   ),
       ('KW', 'KW', 'KWT', '414', N'Kuwait'                                                    ),
       ('KG', 'KG', 'KGZ', '417', N'Kyrgyzstan'                                                ),
       ('LA', 'LA', 'LAO', '418', N'Lao People''s Democratic Republic (the)'                   ),
       ('LV', 'LV', 'LVA', '428', N'Latvia'                                                    ),
       ('LB', 'LB', 'LBN', '422', N'Lebanon'                                                   ),
       ('LS', 'LS', 'LSO', '426', N'Lesotho'                                                   ),
       ('LR', 'LR', 'LBR', '430', N'Liberia'                                                   ),
       ('LY', 'LY', 'LBY', '434', N'Libya'                                                     ),
       ('LI', 'LI', 'LIE', '438', N'Liechtenstein'                                             ),
       ('LT', 'LT', 'LTU', '440', N'Lithuania'                                                 ),
       ('LU', 'LU', 'LUX', '442', N'Luxembourg'                                                ),
       ('MO', 'MO', 'MAC', '446', N'Macao'                                                     ),
       ('MK', 'MK', 'MKD', '807', N'Macedonia (the former Yugoslav Republic of)'               ),
       ('MG', 'MG', 'MDG', '450', N'Madagascar'                                                ),
       ('MW', 'MW', 'MWI', '454', N'Malawi'                                                    ),
       ('MY', 'MY', 'MYS', '458', N'Malaysia'                                                  ),
       ('MV', 'MV', 'MDV', '462', N'Maldives'                                                  ),
       ('ML', 'ML', 'MLI', '466', N'Mali'                                                      ),
       ('MT', 'MT', 'MLT', '470', N'Malta'                                                     ),
       ('MH', 'MH', 'MHL', '584', N'Marshall Islands (the)'                                    ),
       ('MQ', 'MQ', 'MTQ', '474', N'Martinique'                                                ),
       ('MR', 'MR', 'MRT', '478', N'Mauritania'                                                ),
       ('MU', 'MU', 'MUS', '480', N'Mauritius'                                                 ),
       ('YT', 'YT', 'MYT', '175', N'Mayotte'                                                   ),
       ('MX', 'MX', 'MEX', '484', N'Mexico'                                                    ),
       ('FM', 'FM', 'FSM', '583', N'Micronesia (Federated States of)'                          ),
       ('MD', 'MD', 'MDA', '498', N'Moldova (the Republic of)'                                 ),
       ('MC', 'MC', 'MCO', '492', N'Monaco'                                                    ),
       ('MN', 'MN', 'MNG', '496', N'Mongolia'                                                  ),
       ('ME', 'ME', 'MNE', '499', N'Montenegro'                                                ),
       ('MS', 'MS', 'MSR', '500', N'Montserrat'                                                ),
       ('MA', 'MA', 'MAR', '504', N'Morocco'                                                   ),
       ('MZ', 'MZ', 'MOZ', '508', N'Mozambique'                                                ),
       ('MM', 'MM', 'MMR', '104', N'Myanmar'                                                   ),
       ('NA', 'NA', 'NAM', '516', N'Namibia'                                                   ),
       ('NR', 'NR', 'NRU', '520', N'Nauru'                                                     ),
       ('NP', 'NP', 'NPL', '524', N'Nepal'                                                     ),
       ('NL', 'NL', 'NLD', '528', N'Netherlands (the)'                                         ),
       ('NC', 'NC', 'NCL', '540', N'New Caledonia'                                             ),
       ('NZ', 'NZ', 'NZL', '554', N'New Zealand'                                               ),
       ('NI', 'NI', 'NIC', '558', N'Nicaragua'                                                 ),
       ('NE', 'NE', 'NER', '562', N'Niger (the)'                                               ),
       ('NG', 'NG', 'NGA', '566', N'Nigeria'                                                   ),
       ('NU', 'NU', 'NIU', '570', N'Niue'                                                      ),
       ('NF', 'NF', 'NFK', '574', N'Norfolk Island'                                            ),
       ('MP', 'MP', 'MNP', '580', N'Northern Mariana Islands (the)'                            ),
       ('NO', 'NO', 'NOR', '578', N'Norway'                                                    ),
       ('OM', 'OM', 'OMN', '512', N'Oman'                                                      ),
       ('PK', 'PK', 'PAK', '586', N'Pakistan'                                                  ),
       ('PW', 'PW', 'PLW', '585', N'Palau'                                                     ),
       ('PS', 'PS', 'PSE', '275', N'Palestine, State of'                                       ),
       ('PA', 'PA', 'PAN', '591', N'Panama'                                                    ),
       ('PG', 'PG', 'PNG', '598', N'Papua New Guinea'                                          ),
       ('PY', 'PY', 'PRY', '600', N'Paraguay'                                                  ),
       ('PE', 'PE', 'PER', '604', N'Peru'                                                      ),
       ('PH', 'PH', 'PHL', '608', N'Philippines (the)'                                         ),
       ('PN', 'PN', 'PCN', '612', N'Pitcairn'                                                  ),
       ('PL', 'PL', 'POL', '616', N'Poland'                                                    ),
       ('PT', 'PT', 'PRT', '620', N'Portugal'                                                  ),
       ('PR', 'PR', 'PRI', '630', N'Puerto Rico'                                               ),
       ('QA', 'QA', 'QAT', '634', N'Qatar'                                                     ),
       ('RE', 'RE', 'REU', '638', N'R�union'                                                   ),
       ('RO', 'RO', 'ROU', '642', N'Romania'                                                   ),
       ('RU', 'RU', 'RUS', '643', N'Russian Federation (the)'                                  ),
       ('RW', 'RW', 'RWA', '646', N'Rwanda'                                                    ),
       ('BL', 'BL', 'BLM', '652', N'Saint Barth�lemy'                                          ),
       ('SH', 'SH', 'SHN', '654', N'Saint Helena, Ascension and Tristan da Cunha'              ),
       ('KN', 'KN', 'KNA', '659', N'Saint Kitts and Nevis'                                     ),
       ('LC', 'LC', 'LCA', '662', N'Saint Lucia'                                               ),
       ('MF', 'MF', 'MAF', '663', N'Saint Martin (French part)'                                ),
       ('PM', 'PM', 'SPM', '666', N'Saint Pierre and Miquelon'                                 ),
       ('VC', 'VC', 'VCT', '670', N'Saint Vincent and the Grenadines'                          ),
       ('WS', 'WS', 'WSM', '882', N'Samoa'                                                     ),
       ('SM', 'SM', 'SMR', '674', N'San Marino'                                                ),
       ('ST', 'ST', 'STP', '678', N'Sao Tome and Principe'                                     ),
       ('SA', 'SA', 'SAU', '682', N'Saudi Arabia'                                              ),
       ('SN', 'SN', 'SEN', '686', N'Senegal'                                                   ),
       ('RS', 'RS', 'SRB', '688', N'Serbia'                                                    ),
       ('SC', 'SC', 'SYC', '690', N'Seychelles'                                                ),
       ('SL', 'SL', 'SLE', '694', N'Sierra Leone'                                              ),
       ('SG', 'SG', 'SGP', '702', N'Singapore'                                                 ),
       ('SX', 'SX', 'SXM', '534', N'Sint Maarten (Dutch part)'                                 ),
       ('SK', 'SK', 'SVK', '703', N'Slovakia'                                                  ),
       ('SI', 'SI', 'SVN', '705', N'Slovenia'                                                  ),
       ('SB', 'SB', 'SLB', '090', N'Solomon Islands'                                           ),
       ('SO', 'SO', 'SOM', '706', N'Somalia'                                                   ),
       ('ZA', 'ZA', 'ZAF', '710', N'South Africa'                                              ),
       ('GS', 'GS', 'SGS', '239', N'South Georgia and the South Sandwich Islands'              ),
       ('SS', 'SS', 'SSD', '728', N'South Sudan'                                               ),
       ('ES', 'ES', 'ESP', '724', N'Spain'                                                     ),
       ('LK', 'LK', 'LKA', '144', N'Sri Lanka'                                                 ),
       ('SD', 'SD', 'SDN', '729', N'Sudan (the)'                                               ),
       ('SR', 'SR', 'SUR', '740', N'Suriname'                                                  ),
       ('SJ', 'SJ', 'SJM', '744', N'Svalbard and Jan Mayen'                                    ),
       ('SE', 'SE', 'SWE', '752', N'Sweden'                                                    ),
       ('CH', 'CH', 'CHE', '756', N'Switzerland'                                               ),
       ('SY', 'SY', 'SYR', '760', N'Syrian Arab Republic'                                      ),
       ('TW', 'TW', 'TWN', '158', N'Taiwan (Province of China)'                                ),
       ('TJ', 'TJ', 'TJK', '762', N'Tajikistan'                                                ),
       ('TZ', 'TZ', 'TZA', '834', N'Tanzania, United Republic of'                              ),
       ('TH', 'TH', 'THA', '764', N'Thailand'                                                  ),
       ('TL', 'TL', 'TLS', '626', N'Timor-Leste'                                               ),
       ('TG', 'TG', 'TGO', '768', N'Togo'                                                      ),
       ('TK', 'TK', 'TKL', '772', N'Tokelau'                                                   ),
       ('TO', 'TO', 'TON', '776', N'Tonga'                                                     ),
       ('TT', 'TT', 'TTO', '780', N'Trinidad and Tobago'                                       ),
       ('TN', 'TN', 'TUN', '788', N'Tunisia'                                                   ),
       ('TR', 'TR', 'TUR', '792', N'Turkey'                                                    ),
       ('TM', 'TM', 'TKM', '795', N'Turkmenistan'                                              ),
       ('TC', 'TC', 'TCA', '796', N'Turks and Caicos Islands (the)'                            ),
       ('TV', 'TV', 'TUV', '798', N'Tuvalu'                                                    ),
       ('UG', 'UG', 'UGA', '800', N'Uganda'                                                    ),
       ('UA', 'UA', 'UKR', '804', N'Ukraine'                                                   ),
       ('AE', 'AE', 'ARE', '784', N'United Arab Emirates (the)'                                ),
       ('GB', 'GB', 'GBR', '826', N'United Kingdom of Great Britain and Northern Ireland (the)'),
       ('UM', 'UM', 'UMI', '581', N'United States Minor Outlying Islands (the)'                ),
       ('US', 'US', 'USA', '840', N'United States of America (the)'                            ),
       ('UY', 'UY', 'URY', '858', N'Uruguay'                                                   ),
       ('UZ', 'UZ', 'UZB', '860', N'Uzbekistan'                                                ),
       ('VU', 'VU', 'VUT', '548', N'Vanuatu'                                                   ),
       ('VE', 'VE', 'VEN', '862', N'Venezuela (Bolivarian Republic of)'                        ),
       ('VN', 'VN', 'VNM', '704', N'Viet Nam'                                                  ),
       ('VG', 'VG', 'VGB', '092', N'Virgin Islands (British)'                                  ),
       ('VI', 'VI', 'VIR', '850', N'Virgin Islands (U.S.)'                                     ),
       ('WF', 'WF', 'WLF', '876', N'Wallis and Futuna'                                         ),
       ('EH', 'EH', 'ESH', '732', N'Western Sahara'                                            ),
       ('YE', 'YE', 'YEM', '887', N'Yemen'                                                     ),
       ('ZM', 'ZM', 'ZMB', '894', N'Zambia'                                                    ),
       ('ZW', 'ZW', 'ZWE', '716', N'Zimbabwe'                                                  );

MERGE [Lookup].[Country] AS Tgt
USING #Country AS Src
  ON Tgt.[CountryCode] = Src.[CountryCode]
WHEN MATCHED AND EXISTS (
  SELECT Src.[Alpha2ISOCode],
         Src.[Alpha3ISOCode],
		 Src.[NumericISOCode],
		 Src.[ShortNameEnglish]
  EXCEPT 
  SELECT Tgt.[Alpha2ISOCode],
         Tgt.[Alpha3ISOCode],
		 Tgt.[NumericISOCode],
		 Tgt.[ShortNameEnglish]
) THEN 
  UPDATE SET
        Tgt.[Alpha2ISOCode] = Src.[Alpha2ISOCode],
	    Tgt.[Alpha3ISOCode] = Src.[Alpha3ISOCode],
		Tgt.[NumericISOCode] = Src.[NumericISOCode],
		Tgt.[ShortNameEnglish] = Src.[ShortNameEnglish]
  WHEN NOT MATCHED BY TARGET THEN
    INSERT (
	  [SystemFromDate],
	  [SystemtoDate],
      [CountryCode],
	  [Alpha2ISOCode],
	  [Alpha3ISOCode],
	  [NumericISOCode],
	  [ShortNameEnglish]
	)
	VALUES (
	  '1753-01-01',
	  '9999-12-31 23:59:59.9999999',
      [CountryCode],
	  [Alpha2ISOCode],
	  [Alpha3ISOCode],
	  [NumericISOCode],
	  [ShortNameEnglish]
	);
GO
SELECT * FROM [Lookup].[Country];
GO

/* End of File ********************************************************************************************************************/