-- https://douglaskline.blogspot.com/2019/01/the-switchoffset-function.html
-- Database by Doug
-- Douglas Kline
-- 1/30/2019
-- the SwitchOffset function

-- how to use switchoffset 
-- function available beginning SQL 2008

-- see "Time Zones and DATETIMEOFFSET" video

-- an update to the previous video
-- thanks to a viewer who pointed this function out to me
-- you know who you are!

SELECT GETDATE() AS [now, somewhere]

-- my time zone is EST -05:00
-- the server is in the Azure US east data center (EST)

-- note that the GETDATE() returns the time GMT, i.e. -00:00
-- the returned time is 5 hours in the future (based on EST)

-- also note that GETDATE() does not contain the time zone,
-- it returns a datetime, which does not contain time zone information

SELECT SQL_VARIANT_PROPERTY(GETDATE(), 'BaseType')

-- you can the server datetime with time zone like this:

SELECT
    SYSDATETIMEOFFSET(),
    SQL_VARIANT_PROPERTY(SYSDATETIMEOFFSET(), 'BaseType')

-- this result proves that Azure SQL returns UTC 00:00

-- my current database server happens to be
-- in the eastern time zone of the US, which is -05:00 UTC

-- so what is the actual time, in EST?

-- observe the difference between the following values

SELECT
    GETDATE() AS [Azure datetime GMT],
    CAST(GETDATE() AS DATETIMEOFFSET) AS [converted Azure datetime GMT],
    -- but note no hour change
    TODATETIMEOFFSET(GETDATE(), '-05:00') AS [todatetimeoffset result EST],
    SYSDATETIMEOFFSET() AS [sysdatetimeoffset EST],
    -- this is the right one
    SWITCHOFFSET(SYSDATETIMEOFFSET(), '-05:00') AS [switchoffset]

    -- note that GETDATE() is not as accurate  
-- for a couple of reasons
-- fewer decimal points

-- but also 
-- datetimes' one-thousandths place is always 0, 3, or 7   
-- from doc'n "Rounded to increments of .000, .003, or .007 seconds"

-- so, before SWITCHOFFSET existed, ...

SELECT
    SWITCHOFFSET(SYSDATETIMEOFFSET(), '-05:00') AS [EST the easy way],
    TODATETIMEOFFSET(DATEADD(HOUR, -5, SYSDATETIMEOFFSET()), '-05:00')
        AS [EST the hard way]

-- so, thinking of a DATETIMEOFFSET data type as a complex object
-- with many different parts: year, month, day, hour, time zone, etc.
-- it looks like SWITCHOFFSET changes two things: time zone and hour

-- but let's say that my source datetimeoffset 
--   is near a time part boundary, 
--   for example, the end of the year

DECLARE @NewYearsEveEST AS DATETIMEOFFSET
DECLARE @NewYearsEveGMT AS DATETIMEOFFSET

SET
    @NewYearsEveEST
    = DATETIMEOFFSETFROMPARTS(2019, 12, 31, 23, 50, 0, 0, -5, 0, 7)
SET @NewYearsEveGMT = SWITCHOFFSET(@NewYearsEveEST, '+00:00')

SELECT
    @NewYearsEveEST AS [NYEveEST],
    @NewYearsEveGMT AS [NYEveGMT]

-- note that the year, month, day, hour, and time zone changed

-- in summary
-- SWITCHOFFSET is really helpful to have
-- simpler code, likely more reliable
-- use SYSDATETIMEOFFSET to get max precision w/Offset

-- Database by Doug
-- Douglas Kline
-- 1/30/2019
-- the SwitchOffset function
