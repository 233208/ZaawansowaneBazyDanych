CREATE TYPE [dbo].[DatabaseEventsInputTable] AS TABLE (
    [source_id]          UNIQUEIDENTIFIER NOT NULL,
    [source_sequence_id] BIGINT           NOT NULL,
    [start_time]         DATETIME2 (7)    NOT NULL,
    [end_time]           DATETIME2 (7)    NOT NULL,
    [database_name]      [sysname]        NULL,
    [event_category]     NVARCHAR (64)    NOT NULL,
    [event_type]         NVARCHAR (64)    NOT NULL,
    [event_subtype]      INT              NOT NULL,
    [event_count]        INT              NOT NULL,
    [activity_id]        UNIQUEIDENTIFIER NULL,
    [description]        NVARCHAR (MAX)   NULL,
    [additional_data]    XML              NULL);

