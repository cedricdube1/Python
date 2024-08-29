/*****************************************************************************************************************************************************
* Script     : Subscribe IU - Enterprise Platform - Player - 1 Source - 2 Process - 5 Job.sql                                                  *
* Created By : Cedric Dube                                                                                                                            *
* Created On : 2023-03-06                                                                                                                            *
* Updated By : Cedric Dube                                                                                                                             *
* Updated On : 2023-03-06                                                                                                                            *
* Execute On : PROD Environment                                                                                                                      *
* Execute As : Manual                                                                                                                                *
* Execution  : As & when required                                                                                                                    *
* Steps **********************************************************************************************************************************************
* 1 Create Schedule : Only creates the Schedule if missing. This should not need to be changed.                                                 Done *
* 2 Drop & create Job/Steps : Recreates the Job/Steps every time it is run. This should not need to be changed.                                 Done *
* Final Notes ****************************************************************************************************************************************
* {X} Soft Setup : Make any changes in here, specifically to items marked with {X}.                                                                  *
* {C/O} Creator / Owner : Set JobCreator to the current user, ie who is actually running this script.                                                *
*                         Once the Job is created, the owner will be changed to relevant service account (FinalOwner).                               *
*****************************************************************************************************************************************************/


/* End of File **************************************************************************************************************************************/
