import io
import pandas as pd
import requests
from datetime import datetime, timezone
import logging
from typing import Dict, List, Optional
from urllib3 import disable_warnings
from datagate.components.connectors.streams import IStreamConsumer
disable_warnings()

class APICall(IStreamConsumer):

    def __init__(self, **connection_args) -> None:
        
        super().__init__() 
        self.logger = logging.getLogger(__name__)

        self.token : str = None
        self.appid : str = None
        self.apireport : str = None

        for key, value in connection_args.items():
            setattr(self, key, value)

    def read(self, last_processed_timestamp: datetime) -> pd.DataFrame:

        appID = self.appid
        token = self.token
        report = self.apireport
        to_date = datetime.now(timezone.utc) 
        fromDate= datetime.strftime(last_processed_timestamp, "%Y-%m-%d")
        fromHour= datetime.strftime(last_processed_timestamp, "%H")
        fromMinutes= datetime.strftime(last_processed_timestamp, "%M")
        fromSeconds= datetime.strftime(last_processed_timestamp, "%S")
        toDate= datetime.strftime(to_date, "%Y-%m-%d")
        toHour= datetime.strftime(to_date, "%H")
        toMinutes= datetime.strftime(to_date, "%M")
        toSeconds= datetime.strftime(to_date, "%S")

        if report == "installs_report":
            URL_API = "https://hq1.appsflyer.com/api/raw-data/export/app/{}/{}/v5?from={}%20{}%3A{}%3A{}&to={}%20{}%3A{}%3A{}&additional_fields=blocked_reason_rule,store_reinstall,impressions,contributor3_match_type,custom_dimension,conversion_type,gp_click_time,match_type,mediation_network,oaid,deeplink_url,blocked_reason,blocked_sub_reason,gp_broadcast_referrer,gp_install_begin,campaign_type,custom_data,rejected_reason,device_download_time,keyword_match_type,contributor1_match_type,contributor2_match_type,device_model,monetization_network,segment,is_lat,gp_referrer,blocked_reason_value,store_product_page,device_category,app_type,rejected_reason_value,ad_unit,keyword_id,placement,network_account_id,install_app_store,amazon_aid,att,engagement_type,contributor1_engagement_type,contributor2_engagement_type,contributor3_engagement_type,gdpr_applies,ad_user_data_enabled,ad_personalization_enabled"
            URL_API = URL_API.format(appID,report,fromDate, fromHour, fromMinutes, fromSeconds, toDate, toHour, toMinutes, toSeconds)
       

        if report == "in_app_events_report":
            URL_API = "https://hq1.appsflyer.com/api/raw-data/export/app/{}/{}/v5?from={}%20{}%3A{}%3A{}&to={}%20{}%3A{}%3A{}&additional_fields=blocked_reason_rule,store_reinstall,impressions,contributor3_match_type,custom_dimension,conversion_type,gp_click_time,match_type,mediation_network,oaid,deeplink_url,blocked_reason,blocked_sub_reason,gp_broadcast_referrer,gp_install_begin,campaign_type,custom_data,rejected_reason,device_download_time,keyword_match_type,contributor1_match_type,contributor2_match_type,device_model,monetization_network,segment,gp_referrer,blocked_reason_value,device_category,app_type,rejected_reason_value,ad_unit,keyword_id,placement,network_account_id,install_app_store,amazon_aid,att,engagement_type,gdpr_applies,ad_user_data_enabled,ad_personalization_enabled"
            URL_API = URL_API.format(appID,report,fromDate, fromHour, fromMinutes, fromSeconds, toDate, toHour, toMinutes, toSeconds)
       
        headers = {
            "accept": "text/csv",
            "authorization": "" 
        }

        header_key = "authorization"
        headers.update({header_key: token})
        response = requests.get(URL_API, headers= headers, verify=False,)
        end_time = datetime.now().strftime("%d-%b-%Y %H:%M:%S")

        if response.status_code == 200:

            response = response.content
            df = pd.read_csv(io.StringIO(response.decode('utf-8')),low_memory=False)
            
            self.logger.warning("Successfully api request was made at : {}".format(end_time))

            if df is not None:
                self.logger.warning("Number of Records read: {}".format(len(df)))  

            return df
        
        if response.status_code == 400:
            self.logger.warning("You've reached your maximum number of api calls for the day.")  

        if response.status_code == 401:
            self.logger.warning("Account may be suspended or You've reached your maximum number of request for the day.")  

        if response.status_code == 404:
            self.logger.warning("AppID was not found. Check if you are using correct token or a valid AppID.")  
          
    def store_offsets(self,) -> None:
        pass
    
    def commit(self) -> None:
        pass

    def close(self) -> None:
        pass