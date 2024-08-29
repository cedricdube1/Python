from datetime import datetime, timedelta, timezone
import logging
import pyodbc
import pandas as pd
from typing import Dict, Optional, Union, List
from datagate.components.connectors.stores import IStore

class SQLServerProc(IStore):
    def __init__(self, **connection_args):
        super().__init__()

        self.logger = logging.getLogger(__name__)

        self.appid2: str = None
        self.server: str = None
        self.database: str = None
        self.username: Optional[str] = None
        self.password: Optional[str] = None
        self.driver: str = "ODBC Driver 17 for SQL Server"
        self.port: int = 1433
        self.config: str = None
        self.table: str = None
        self.schema: str = None
        self.report: str = None
        self.odbc_kwargs: Optional[Dict[str, Union[str, int]]] = None
        self.connection_name: str = 'python_api'
        self.auto_commit: bool = True

        for key, value in connection_args.items():
            setattr(self, key, value)

    def create_connection(self):
        driver = "{" + self.driver + "}"
        server=self.server
        database=self.database
        user=self.username
        password=self.password
        connection_string = f'DRIVER={driver};SERVER={server};DATABASE={database};UID={user};PWD={password}'
        return pyodbc.connect(connection_string)   
    
    def read(self) -> datetime:
        """
        Gets the latest timestamp from the config table
        """
        conn = self.create_connection()

        cursor = conn.cursor()
        qry = "SELECT MaxEventTime FROM [dbo].[{}Cofig] WITH (NOLOCK) WHERE AppID = '{}' AND report = '{}'".format(self.table, self.appid2, self.report)
        last_processed = cursor.execute(qry).fetchval()

        conn.commit()
        conn.close()

        end = datetime.now().strftime("%d-%b-%Y %H:%M:%S")          

        if last_processed is None and self.report == "installs_report":
            todayUTC = datetime.now(timezone.utc)
            last_processed = todayUTC - timedelta(60) #reports are limited to 60  days per query
            self.logger.warning("Couldn't find last procesed timestamp from SQL, we defaulted the timestamp at: {}".format(end))            
            return last_processed
        if last_processed is None and self.report == "in_app_events_report":
            todayUTC = datetime.now(timezone.utc)
            last_processed = todayUTC - timedelta(1) #reports are limited to 60  days per query
            self.logger.warning("Couldn't find last procesed timestamp from SQL, we defaulted the timestamp at: {}".format(end))            
            return last_processed
        else:
            self.logger.warning("Successfully read the last procesed timestamp from SQL at: {}".format(end))
            last_processed = last_processed + timedelta(seconds=1)
            return last_processed
            
    def write(self, record_list: pd.DataFrame):

        successful = False
        startTime = datetime.now().strftime("%d-%b-%Y %H:%M:%S") 
        conn:any = None
        try:
            conn = self.create_connection()

            df= record_list
            count = len(record_list)

            cursor = conn.cursor()

            # Fomulate an insert script
            qry = """INSERT INTO [{schema}].[{table}]("""
            qry = qry.format(schema=self.schema, table=self.table)
            cols = ",".join([str(i) for i in df.columns.tolist()])
            val = ",".join([str("""?""") for i in df.columns.tolist()])
            qry = qry + cols + ") VALUES (" + val + ");"

            self.logger.warning("Started writing to SQL at: {}".format(startTime))

            
            # Insert DataFrame records one by one.
            if self.report == "in_app_events_report":
                for i,row in df.iterrows():
                    insert_list = row.AttributedTouchType,row.AttributedTouchTime,row.InstallTime,row.EventTime,row.EventName,row.EventValue,row.EventRevenue,row.EventRevenueCurrency,row.EventRevenueUSD,row.EventSource,row.IsReceiptValidated,row.Partner,row.MediaSource,row.Channel,row.Keywords,row.Campaign,row.CampaignID,row.Adset,row.AdsetID,row.Ad,row.AdID,row.AdType,row.SiteID,row.SubSiteID,row.SubParam1,row.SubParam2,row.SubParam3,row.SubParam4,row.SubParam5,row.CostModel,row.CostValue,row.CostCurrency,row.Contributor1Partner,row.Contributor1MediaSource,row.Contributor1Campaign,row.Contributor1TouchType,row.Contributor1TouchTime,row.Contributor2Partner,row.Contributor2MediaSource,row.Contributor2Campaign,row.Contributor2TouchType,row.Contributor2TouchTime,row.Contributor3Partner,row.Contributor3MediaSource,row.Contributor3Campaign,row.Contributor3TouchType,row.Contributor3TouchTime,row.Region,row.CountryCode,row.State,row.City,row.PostalCode,row.DMA,row.IP,row.WIFI,row.Operator,row.Carrier,row.Language,row.AppsFlyerID,row.AdvertisingID,row.IDFA,row.AndroidID,row.CustomerUserID,row.IMEI,row.IDFV,row.Platform,row.DeviceType,row.OSVersion,row.AppVersion,row.SDKVersion,row.AppID,row.AppName,row.BundleID,row.IsRetargeting,row.RetargetingConversionType,row.AttributionLookback,row.ReengagementWindow,row.IsPrimaryAttribution,row.UserAgent,row.HTTPReferrer,row.OriginalURL,row.BlockedReasonRule,row.StoreReinstall,row.Impressions,row.Contributor3MatchType,row.CustomDimension,row.ConversionType,row.GooglePlayClickTime,row.MatchType,row.MediationNetwork,row.OAID,row.DeeplinkURL,row.BlockedReason,row.BlockedSubReason,row.GooglePlayBroadcastReferrer,row.GooglePlayInstallBeginTime,row.CampaignType,row.CustomData,row.RejectedReason,row.DeviceDownloadTime,row.KeywordMatchType,row.Contributor1MatchType,row.Contributor2MatchType,row.DeviceModel,row.MonetizationNetwork,row.Segment,row.GooglePlayReferrer,row.BlockedReasonValue,row.DeviceCategory,row.AppType,row.RejectedReasonValue,row.AdUnit,row.KeywordID,row.Placement,row.NetworkAccountID,row.InstallAppStore,row.AmazonFireID,row.ATT,row.EngagementType,row.GDPRApplies,row.AdUserDataEnabled,row.AdPersonalizationEnabled
                    cursor.fast_executemany = True
                    cursor.execute(qry, insert_list)
                    conn.commit()
            else:
                for i,row in df.iterrows():
                    insert_list = row.AttributedTouchType,row.AttributedTouchTime,row.InstallTime,row.EventTime,row.EventName,row.EventValue,row.EventRevenue,row.EventRevenueCurrency,row.EventRevenueUSD,row.EventSource,row.IsReceiptValidated,row.Partner,row.MediaSource,row.Channel,row.Keywords,row.Campaign,row.CampaignID,row.Adset,row.AdsetID,row.Ad,row.AdID,row.AdType,row.SiteID,row.SubSiteID,row.SubParam1,row.SubParam2,row.SubParam3,row.SubParam4,row.SubParam5,row.CostModel,row.CostValue,row.CostCurrency,row.Contributor1Partner,row.Contributor1MediaSource,row.Contributor1Campaign,row.Contributor1TouchType,row.Contributor1TouchTime,row.Contributor2Partner,row.Contributor2MediaSource,row.Contributor2Campaign,row.Contributor2TouchType,row.Contributor2TouchTime,row.Contributor3Partner,row.Contributor3MediaSource,row.Contributor3Campaign,row.Contributor3TouchType,row.Contributor3TouchTime,row.Region,row.CountryCode,row.State,row.City,row.PostalCode,row.DMA,row.IP,row.WIFI,row.Operator,row.Carrier,row.Language,row.AppsFlyerID,row.AdvertisingID,row.IDFA,row.AndroidID,row.CustomerUserID,row.IMEI,row.IDFV,row.Platform,row.DeviceType,row.OSVersion,row.AppVersion,row.SDKVersion,row.AppID,row.AppName,row.BundleID,row.IsRetargeting,row.RetargetingConversionType,row.AttributionLookback,row.ReengagementWindow,row.IsPrimaryAttribution,row.UserAgent,row.HTTPReferrer,row.OriginalURL,row.BlockedReasonRule,row.StoreReinstall,row.Impressions,row.Contributor3MatchType,row.CustomDimension,row.ConversionType,row.GooglePlayClickTime,row.MatchType,row.MediationNetwork,row.OAID,row.DeeplinkURL,row.BlockedReason,row.BlockedSubReason,row.GooglePlayBroadcastReferrer,row.GooglePlayInstallBeginTime,row.CampaignType,row.CustomData,row.RejectedReason,row.DeviceDownloadTime,row.KeywordMatchType,row.Contributor1MatchType,row.Contributor2MatchType,row.DeviceModel,row.MonetizationNetwork,row.Segment,row.IsLAT,row.GooglePlayReferrer,row.BlockedReasonValue,row.StoreProductPage,row.DeviceCategory,row.AppType,row.RejectedReasonValue,row.AdUnit,row.KeywordID,row.Placement,row.NetworkAccountID,row.InstallAppStore,row.AmazonFireID,row.ATT,row.EngagementType,row.Contributor1EngagementType,row.Contributor2EngagementType,row.Contributor3EngagementType,row.GDPRApplies,row.AdUserDataEnabled,row.AdPersonalizationEnabled
                    cursor.fast_executemany = True
                    cursor.execute(qry, insert_list)
                    conn.commit()

            endTime = datetime.now().strftime("%d-%b-%Y %H:%M:%S")          

        except Exception as err:
            successful = False
            self.logger.error("Error during SQL write: {}".format(err))
            raise err
        else:
            successful = True
        finally:
            if conn is not None:
                conn.close()
            self.logger.warning("Successfully finished writing to SQL at: {}".format(endTime))
            self.logger.warning("Number of Records written: {}".format(count))  
            return successful
        
    def update(self, record: pd.DataFrame):
        conn = self.create_connection()

        last_processed = max(record['EventTime'])
        cursor = conn.cursor()
        #qry = "SELECT MAX(EventTime) FROM {}.{} WITH (NOLOCK)".format(self.schema,self.table)
        qry = "UPDATE [dbo].[{}Cofig] SET MaxEventTime = ? WHERE AppID = '{}' AND report = '{}'".format(self.table, self.appid2 ,self.report)
        cursor.execute(qry, last_processed)

        conn.commit()
        conn.close()

        end = datetime.now().strftime("%d-%b-%Y %H:%M:%S") 

        self.logger.warning("Successfully update timestamp to SQL at: {}".format(end))
