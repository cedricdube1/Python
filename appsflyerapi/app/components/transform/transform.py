import logging
import pandas as pd
from datagate.components import IProcessor
from datagate.components.utils import mapper

class Transform(IProcessor):
    def __init__(self,**connection_args)-> None:
        super().__init__()
        self.logger = logging.getLogger(__name__)
        self.apireport2 : str = None


        for key, value in connection_args.items():
            setattr(self, key, value)
    
    def process(self, response: pd.DataFrame) -> pd.DataFrame:
        
        df =  response
        report = self.apireport2
        df.columns = df.columns.str.replace(' ', '')

        if report == "installs_report":
             df = df.fillna({
                 'Contributor1EngagementType': 'Unknown',
                 'Contributor2EngagementType': 'Unknown',
                 'Contributor3EngagementType': 'Unknown',})
             df['IsLAT'].astype('bool')

        df = df.fillna({
            'AttributedTouchType': 'Unknown',
            'AttributedTouchTime': '1900-01-01 00:00:00.000',
            'EventValue': 'Unknown',
            'EventRevenue': 0,
            'EventRevenueCurrency': 'Unknown',
            'EventRevenueUSD': 0,
            'IsReceiptValidated': False,
            'Partner': 'Unknown',
            'MediaSource': 'Unknown',
            'Channel': 'Unknown',
            'Keywords': 'Unknown',
            'Campaign': 'Unknown',
            'CampaignID': 'Unknown',
            'Adset': 'Unknown',
            'AdsetID': 'Unknown',
            'Ad': 'Unknown',
            'AdID': 'Unknown',
            'AdType': 'Unknown',
            'SiteID': 'Unknown',
            'SubSiteID': 'Unknown',
            'SubParam1': 'Unknown',
            'SubParam2': 'Unknown',
            'SubParam3': 'Unknown',
            'SubParam4': 'Unknown',
            'SubParam5': 'Unknown',
            'CostModel': 'Unknown',
            'CostValue': 0,
            'CostCurrency': 'Unknown',
            'Contributor1Partner': 'Unknown',
            'Contributor1MediaSource': 'Unknown',
            'Contributor1Campaign': 'Unknown',
            'Contributor1TouchType': 'Unknown',
            'Contributor1TouchTime': '1900-01-01 00:00:00.000',
            'Contributor2Partner': 'Unknown',
            'Contributor2MediaSource': 'Unknown',
            'Contributor2Campaign': 'Unknown',
            'Contributor2TouchType': 'Unknown',
            'Contributor2TouchTime': '1900-01-01 00:00:00.000',
            'Contributor3Partner': 'Unknown',
            'Contributor3MediaSource': 'Unknown',
            'Contributor3Campaign': 'Unknown',
            'Contributor3TouchType': 'Unknown',
            'Contributor3TouchTime': '1900-01-01 00:00:00.000',
            'Region': 'Unknown',
            'CountryCode': 'Unknown',
            'State': 'Unknown',
            'City': 'Unknown',
            'PostalCode': 'Unknown',
            'Operator': 'Unknown',
            'Carrier': 'Unknown',
            'Language': 'Unknown',
            'AdvertisingID': 'Unknown',
            'IDFA': 'Unknown',
            'AndroidID': 'Unknown',
            'CustomerUserID': 'Unknown',
            'IMEI': 'Unknown',
            'DeviceType': 'Unknown',
            'RetargetingConversionType': 'Unknown',
            'AttributionLookback': 'Unknown',
            'ReengagementWindow': 'Unknown',
            'IsPrimaryAttribution': False,
            'HTTPReferrer': 'Unknown',
            'OriginalURL': 'Unknown',
            'BlockedReasonRule': 'Unknown',
            'StoreReinstall': False,
            'Impressions': 'Unknown',
            'Contributor3MatchType': 'Unknown',
            'CustomDimension': 'Unknown',
            'ConversionType': 'Unknown',
            'GooglePlayClickTime': '1900-01-01 00:00:00.000',
            'MatchType': 'Unknown',
            'MediationNetwork': 'Unknown',
            'OAID': 'Unknown',
            'DeeplinkURL': 'Unknown',
            'BlockedReason': 'Unknown',
            'BlockedSubReason': 'Unknown',
            'GooglePlayBroadcastReferrer': 'Unknown',
            'GooglePlayInstallBeginTime': '1900-01-01 00:00:00.000',
            'CustomData': 'Unknown',
            'RejectedReason': 'Unknown',
            'KeywordMatchType': 'Unknown',
            'Contributor1MatchType': 'Unknown',
            'Contributor2MatchType': 'Unknown',
            'MonetizationNetwork': 'Unknown',
            'Segment': 'Unknown',        
            'GooglePlayReferrer': 'Unknown',
            'BlockedReasonValue': 'Unknown',
            'StoreProductPage': 'Unknown',
            'DeviceCategory': 'Unknown',
            'RejectedReasonValue': 'Unknown',
            'AdUnit': 'Unknown',
            'KeywordID': -1,
            'Placement': 'Unknown',
            'NetworkAccountID':-1,
            'InstallAppStore': 'Unknown',
            'AmazonFireID': 'Unknown', #might change to int
            'EngagementType': 'Unknown',            
            'GDPRApplies': False,
            'AdUserDataEnabled': False,
            'AdPersonalizationEnabled': False
            })

        df['AttributedTouchTime'].astype('datetime64')
        df['Contributor1TouchTime'].astype('datetime64')
        df['Contributor2TouchTime'].astype('datetime64')
        df['Contributor3TouchTime'].astype('datetime64')
        df['GooglePlayClickTime'].astype('datetime64')
        df['GooglePlayInstallBeginTime'].astype('datetime64')
        df['IsReceiptValidated'].astype('bool')
        df['WIFI'].astype('bool')
        df['IsRetargeting'].astype('bool')
        df['IsPrimaryAttribution'].astype('bool')
        df['StoreReinstall'].astype('bool')        
        df['GDPRApplies'].astype('bool')
        df['AdUserDataEnabled'].astype('bool')
        df['KeywordID'].astype('int')
        df['NetworkAccountID'].astype('int')
        return df    