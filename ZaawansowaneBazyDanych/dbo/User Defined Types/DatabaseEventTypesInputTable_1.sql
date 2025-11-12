CREATE TYPE [dbo].[DatabaseEventTypesInputTable] AS TABLE (
    [event_category]     NVARCHAR (64)  NULL,
    [event_type]         NVARCHAR (64)  NULL,
    [event_subtype]      INT            NULL,
    [event_subtype_desc] NVARCHAR (64)  NULL,
    [severity]           INT            NULL,
    [description]        NVARCHAR (MAX) NULL);

