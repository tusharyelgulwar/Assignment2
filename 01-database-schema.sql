-- =============================================
-- Logistics KPI Dashboard - Database Schema
-- =============================================
-- This script creates the complete database structure for a logistics
-- transportation management system with optimized tables for Power BI reporting

USE master;
GO

-- Drop database if exists and create new one
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'LogisticsKPI')
    DROP DATABASE LogisticsKPI;
GO

CREATE DATABASE LogisticsKPI;
GO

USE LogisticsKPI;
GO

-- =============================================
-- DIMENSION TABLES
-- =============================================

-- Carriers dimension table
CREATE TABLE dbo.Carriers (
    CarrierID INT IDENTITY(1,1) NOT NULL,
    CarrierName NVARCHAR(100) NOT NULL,
    CarrierCode NVARCHAR(10) NOT NULL,
    ContactEmail NVARCHAR(100),
    PhoneNumber NVARCHAR(20),
    ServiceTypes NVARCHAR(200), -- Standard, Express, Overnight
    CoverageRegions NVARCHAR(500), -- Regions they serve
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT PK_Carriers PRIMARY KEY (CarrierID),
    CONSTRAINT UK_Carriers_Code UNIQUE (CarrierCode)
);

-- Customers dimension table
CREATE TABLE dbo.Customers (
    CustomerID INT IDENTITY(1,1) NOT NULL,
    CustomerName NVARCHAR(100) NOT NULL,
    CustomerCode NVARCHAR(10) NOT NULL,
    Region NVARCHAR(50) NOT NULL,
    City NVARCHAR(50) NOT NULL,
    State NVARCHAR(50) NOT NULL,
    PostalCode NVARCHAR(10),
    Country NVARCHAR(50) NOT NULL DEFAULT 'USA',
    CustomerType NVARCHAR(50) DEFAULT 'Business', -- Business, Individual
    Industry NVARCHAR(100), -- Manufacturing, Retail, etc.
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT PK_Customers PRIMARY KEY (CustomerID),
    CONSTRAINT UK_Customers_Code UNIQUE (CustomerCode)
);

-- Routes dimension table
CREATE TABLE dbo.Routes (
    RouteID INT IDENTITY(1,1) NOT NULL,
    OriginCity NVARCHAR(50) NOT NULL,
    OriginState NVARCHAR(50) NOT NULL,
    OriginPostalCode NVARCHAR(10),
    DestinationCity NVARCHAR(50) NOT NULL,
    DestinationState NVARCHAR(50) NOT NULL,
    DestinationPostalCode NVARCHAR(10),
    DistanceMiles DECIMAL(8,2),
    EstimatedTransitDays INT NOT NULL,
    RouteType NVARCHAR(20) NOT NULL DEFAULT 'Standard', -- Standard, Express, Overnight
    RouteCategory NVARCHAR(50) DEFAULT 'Domestic', -- Domestic, International
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT PK_Routes PRIMARY KEY (RouteID)
);

-- =============================================
-- FACT TABLE
-- =============================================

-- Main Shipments fact table
CREATE TABLE dbo.Shipments (
    ShipmentID INT IDENTITY(1,1) NOT NULL,
    TrackingNumber NVARCHAR(50) NOT NULL,
    CustomerID INT NOT NULL,
    CarrierID INT NOT NULL,
    RouteID INT NOT NULL,
    
    -- Shipment Details
    ShipDate DATETIME2 NOT NULL,
    EstimatedDeliveryDate DATETIME2 NOT NULL,
    ActualDeliveryDate DATETIME2 NULL,
    
    -- Package Details
    Weight DECIMAL(8,2) NOT NULL,
    Volume DECIMAL(8,2),
    DeclaredValue DECIMAL(10,2),
    PackageCount INT DEFAULT 1,
    
    -- Financial Details
    ShippingCost DECIMAL(10,2) NOT NULL,
    InsuranceCost DECIMAL(10,2) DEFAULT 0,
    FuelSurcharge DECIMAL(10,2) DEFAULT 0,
    TotalCost AS (ShippingCost + InsuranceCost + FuelSurcharge) PERSISTED,
    
    -- Service Details
    ServiceLevel NVARCHAR(20) NOT NULL, -- Standard, Express, Overnight
    Priority NVARCHAR(20) DEFAULT 'Normal', -- Normal, High, Critical
    
    -- Status Tracking
    Status NVARCHAR(20) NOT NULL DEFAULT 'In Transit', -- In Transit, Delivered, Exception, Returned
    LastUpdated DATETIME2 NOT NULL DEFAULT GETDATE(),
    
    -- Audit Fields
    CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT PK_Shipments PRIMARY KEY (ShipmentID),
    CONSTRAINT FK_Shipments_Customers FOREIGN KEY (CustomerID) REFERENCES dbo.Customers(CustomerID),
    CONSTRAINT FK_Shipments_Carriers FOREIGN KEY (CarrierID) REFERENCES dbo.Carriers(CarrierID),
    CONSTRAINT FK_Shipments_Routes FOREIGN KEY (RouteID) REFERENCES dbo.Routes(RouteID),
    CONSTRAINT UK_Shipments_Tracking UNIQUE (TrackingNumber)
);

-- =============================================
-- EXCEPTION TRACKING
-- =============================================

-- Delivery Exceptions table
CREATE TABLE dbo.DeliveryExceptions (
    ExceptionID INT IDENTITY(1,1) NOT NULL,
    ShipmentID INT NOT NULL,
    ExceptionType NVARCHAR(50) NOT NULL, -- Damaged, Lost, Delayed, Weather, Address Issue, Customs, etc.
    ExceptionDescription NVARCHAR(500),
    ExceptionDate DATETIME2 NOT NULL,
    ResolvedDate DATETIME2 NULL,
    ResolutionNotes NVARCHAR(500),
    CostImpact DECIMAL(10,2) NOT NULL DEFAULT 0,
    ResponsibleParty NVARCHAR(100), -- Carrier, Customer, Third Party
    Severity NVARCHAR(20) DEFAULT 'Medium', -- Low, Medium, High, Critical
    CreatedDate DATETIME2 NOT NULL DEFAULT GETDATE(),
    ModifiedDate DATETIME2 NOT NULL DEFAULT GETDATE(),
    
    CONSTRAINT PK_DeliveryExceptions PRIMARY KEY (ExceptionID),
    CONSTRAINT FK_Exceptions_Shipments FOREIGN KEY (ShipmentID) REFERENCES dbo.Shipments(ShipmentID)
);

-- =============================================
-- PERFORMANCE INDEXES
-- =============================================

-- Shipments table indexes for Power BI performance
CREATE INDEX IX_Shipments_ShipDate ON dbo.Shipments(ShipDate);
CREATE INDEX IX_Shipments_ActualDeliveryDate ON dbo.Shipments(ActualDeliveryDate);
CREATE INDEX IX_Shipments_Status ON dbo.Shipments(Status);
CREATE INDEX IX_Shipments_CarrierID ON dbo.Shipments(CarrierID);
CREATE INDEX IX_Shipments_CustomerID ON dbo.Shipments(CustomerID);
CREATE INDEX IX_Shipments_RouteID ON dbo.Shipments(RouteID);
CREATE INDEX IX_Shipments_ServiceLevel ON dbo.Shipments(ServiceLevel);
CREATE INDEX IX_Shipments_Composite_Date_Carrier ON dbo.Shipments(ShipDate, CarrierID);

-- Customer table indexes
CREATE INDEX IX_Customers_Region ON dbo.Customers(Region);
CREATE INDEX IX_Customers_State ON dbo.Customers(State);
CREATE INDEX IX_Customers_Industry ON dbo.Customers(Industry);

-- Exception table indexes
CREATE INDEX IX_Exceptions_ExceptionDate ON dbo.DeliveryExceptions(ExceptionDate);
CREATE INDEX IX_Exceptions_ExceptionType ON dbo.DeliveryExceptions(ExceptionType);
CREATE INDEX IX_Exceptions_ResolvedDate ON dbo.DeliveryExceptions(ResolvedDate);

-- =============================================
-- POWER BI OPTIMIZED VIEWS
-- =============================================

-- Main fact view for Power BI
CREATE VIEW dbo.vw_ShipmentKPIs AS
SELECT 
    s.ShipmentID,
    s.TrackingNumber,
    s.ShipDate,
    s.EstimatedDeliveryDate,
    s.ActualDeliveryDate,
    s.Weight,
    s.Volume,
    s.DeclaredValue,
    s.PackageCount,
    s.ShippingCost,
    s.InsuranceCost,
    s.FuelSurcharge,
    s.TotalCost,
    s.ServiceLevel,
    s.Priority,
    s.Status,
    
    -- Calculated Performance Fields
    DATEDIFF(DAY, s.ShipDate, s.ActualDeliveryDate) as ActualTransitDays,
    DATEDIFF(DAY, s.ShipDate, s.EstimatedDeliveryDate) as EstimatedTransitDays,
    DATEDIFF(DAY, s.EstimatedDeliveryDate, s.ActualDeliveryDate) as DeliveryVariance,
    
    -- On-Time Delivery Flag
    CASE 
        WHEN s.ActualDeliveryDate IS NULL THEN 0
        WHEN s.ActualDeliveryDate <= s.EstimatedDeliveryDate THEN 1 
        ELSE 0 
    END as IsOnTime,
    
    -- Delivery Performance Category
    CASE 
        WHEN s.ActualDeliveryDate IS NULL THEN 'Not Delivered'
        WHEN s.ActualDeliveryDate <= s.EstimatedDeliveryDate THEN 'On Time'
        WHEN DATEDIFF(DAY, s.EstimatedDeliveryDate, s.ActualDeliveryDate) <= 1 THEN '1 Day Late'
        WHEN DATEDIFF(DAY, s.EstimatedDeliveryDate, s.ActualDeliveryDate) <= 3 THEN '2-3 Days Late'
        ELSE 'More than 3 Days Late'
    END as DeliveryPerformance,
    
    -- Customer Information
    c.CustomerName,
    c.CustomerCode,
    c.Region,
    c.City,
    c.State,
    c.Country,
    c.CustomerType,
    c.Industry,
    
    -- Carrier Information
    car.CarrierName,
    car.CarrierCode,
    car.ServiceTypes,
    car.CoverageRegions,
    
    -- Route Information
    rt.OriginCity,
    rt.OriginState,
    rt.DestinationCity,
    rt.DestinationState,
    rt.DistanceMiles,
    rt.RouteType,
    rt.RouteCategory,
    
    -- Exception Information
    CASE WHEN e.ExceptionID IS NOT NULL THEN 1 ELSE 0 END as HasException,
    e.ExceptionType,
    e.ExceptionDescription,
    e.CostImpact,
    e.Severity,
    e.ResponsibleParty,
    
    -- Time Dimensions
    YEAR(s.ShipDate) as ShipYear,
    MONTH(s.ShipDate) as ShipMonth,
    DATENAME(MONTH, s.ShipDate) as ShipMonthName,
    DATEPART(QUARTER, s.ShipDate) as ShipQuarter,
    DATENAME(WEEKDAY, s.ShipDate) as ShipDayName,
    DATEPART(WEEK, s.ShipDate) as ShipWeekOfYear

FROM dbo.Shipments s
INNER JOIN dbo.Customers c ON s.CustomerID = c.CustomerID
INNER JOIN dbo.Carriers car ON s.CarrierID = car.CarrierID
INNER JOIN dbo.Routes rt ON s.RouteID = rt.RouteID
LEFT JOIN dbo.DeliveryExceptions e ON s.ShipmentID = e.ShipmentID;

-- Date dimension view for Power BI
CREATE VIEW dbo.vw_DateTable AS
SELECT DISTINCT
    ShipDate as Date,
    YEAR(ShipDate) as Year,
    MONTH(ShipDate) as Month,
    DAY(ShipDate) as Day,
    DATENAME(MONTH, ShipDate) as MonthName,
    DATENAME(WEEKDAY, ShipDate) as DayName,
    DATEPART(WEEK, ShipDate) as WeekOfYear,
    DATEPART(QUARTER, ShipDate) as Quarter,
    DATENAME(QUARTER, ShipDate) as QuarterName,
    CASE 
        WHEN MONTH(ShipDate) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(ShipDate) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(ShipDate) IN (6, 7, 8) THEN 'Summer'
        ELSE 'Fall'
    END as Season,
    CASE 
        WHEN DATEPART(WEEKDAY, ShipDate) IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END as DayType
FROM dbo.Shipments;

PRINT 'Database schema created successfully!';
PRINT 'Tables created: Carriers, Customers, Routes, Shipments, DeliveryExceptions';
PRINT 'Views created: vw_ShipmentKPIs, vw_DateTable';
PRINT 'Indexes created for optimal Power BI performance';
