/************************************************************************
* Script     : 3.Business - PlayerAcquisitionOffer - Tables.sql
* Created By : Cedric Dube
* Created On : 2021-08-12
* Execute On : As required.
* Execute As : N/A
* Execution  : Entire script once.
* Version    : 1.0
************************************************************************/
USE [dbSurge]
GO

CREATE TABLE [dbo].[PlayerAcquisitionOffer] (
  -- Standard Columns --
  [HubPlayerID] BINARY(32) NOT NULl,
  [SourceSystemID] INT NOT NULL,
  CONSTRAINT [FK1_PlayerAcquisitionOffer_HubPlayer] FOREIGN KEY ([HubPlayerID], [SourceSystemID]) REFERENCES [dbo].[HubPlayer] ([HubPlayerID], [SourceSystemID]),
  CONSTRAINT [PK_PlayerAcquisitionOffer] PRIMARY KEY CLUSTERED (
    [HubPlayerID] ASC,
    [SourceSystemID] ASC
  ) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90),
  [OriginSystemID] INT NOT NULL,
  [CaptureLogID] BIGINT NOT NULL,
  [Operation] CHAR(1) NOT NULL,
  [ModifiedDate] DATETIME2 NOT NULL,
  -- Specific Columns --
  [CompletionReasonID] INT,
  [RegistrationUTCDateTime] DATETIME2 NULL,
  [RegistrationUTCDate] DATE NULL,
  [CompletionUTCDateTime] DATETIME2 NULL,
  [CompletionUTCDate] DATE NULL,
  [NumberOfConversions] INT NULL,
  [NumberOfDeposits] INT NULL
) ON [PRIMARY]; 
GO
CREATE NONCLUSTERED INDEX [IDX_CaptureLog] ON [dbo].[PlayerAcquisitionOffer] (
  [CaptureLogID] ASC
) INCLUDE (
  [ModifiedDate]
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO
CREATE NONCLUSTERED INDEX [IDX_ModifiedDate] ON [dbo].[PlayerAcquisitionOffer] (
  [ModifiedDate] ASC
) INCLUDE (
  [CaptureLogID]
) WITH (DATA_COMPRESSION = PAGE, FILLFACTOR = 90);
GO
CREATE NONCLUSTERED COLUMNSTORE INDEX [IDX_NCCS] ON [dbo].[PlayerAcquisitionOffer] (
  -- Standard Columns --
  [CaptureLogID],
  [Operation],
  [ModifiedDate],
  -- Specific Columns --
  [CompletionReasonID],
  [RegistrationUTCDateTime],
  [RegistrationUTCDate] ,
  [CompletionUTCDateTime],
  [CompletionUTCDate],
  [NumberOfConversions],
  [NumberOfDeposits]
) WITH (DROP_EXISTING = OFF, COMPRESSION_DELAY = 0);
GO
                                                                                                                                                                                                                                    
-- ADD CONSTRAINTS TO REFERENCE TABLES --
ALTER TABLE [dbo].[PlayerAcquisitionOffer]
  ADD CONSTRAINT [FK_PlayerAcquisitionOffer_Reason] FOREIGN KEY ([CompletionReasonID]) REFERENCES [dbo].[Reason] ([ReasonID]);
GO

-- INSERT DEFAULT HUB --
INSERT INTO [dbo].[PlayerAcquisitionOffer] (
  [HubPlayerID],
  [SourceSystemID],
  [ModifiedDate],
  [OriginSystemID],
  [CapturelogID],
  [Operation]
) VALUES (0x0000000000000000000000000000000000000000000000000000000000000000, -1, '1900-01-01', -1, -1, 'I');
GO

/* End of File ********************************************************************************************************************/