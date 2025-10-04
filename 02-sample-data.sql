-- =============================================
-- Logistics KPI Dashboard - Sample Data
-- =============================================
-- This script populates the database with realistic sample data for testing
-- and demonstration purposes

USE LogisticsKPI;
GO

-- Clear existing data
DELETE FROM dbo.DeliveryExceptions;
DELETE FROM dbo.Shipments;
DELETE FROM dbo.Routes;
DELETE FROM dbo.Customers;
DELETE FROM dbo.Carriers;
GO

-- Reset identity columns
DBCC CHECKIDENT('dbo.DeliveryExceptions', RESEED, 0);
DBCC CHECKIDENT('dbo.Shipments', RESEED, 0);
DBCC CHECKIDENT('dbo.Routes', RESEED, 0);
DBCC CHECKIDENT('dbo.Customers', RESEED, 0);
DBCC CHECKIDENT('dbo.Carriers', RESEED, 0);
GO

-- =============================================
-- INSERT CARRIERS
-- =============================================

INSERT INTO dbo.Carriers (CarrierName, CarrierCode, ContactEmail, PhoneNumber, ServiceTypes, CoverageRegions) VALUES
('FedEx Express', 'FDX', 'support@fedex.com', '1-800-GO-FEDEX', 'Standard, Express, Overnight', 'Nationwide'),
('UPS Ground', 'UPS', 'customer@ups.com', '1-800-PICK-UPS', 'Standard, Express, Overnight', 'Nationwide'),
('DHL Express', 'DHL', 'service@dhl.com', '1-800-CALL-DHL', 'Express, Overnight', 'Nationwide'),
('USPS Priority', 'USPS', 'help@usps.com', '1-800-ASK-USPS', 'Standard, Express', 'Nationwide'),
('Amazon Logistics', 'AMZN', 'support@amazon.com', '1-888-280-4331', 'Standard, Express', 'Major Cities'),
('XPO Logistics', 'XPO', 'service@xpo.com', '1-866-XPO-LOGS', 'Standard, Express', 'Nationwide'),
('Old Dominion', 'ODFL', 'info@odfl.com', '1-800-OLD-DOMAIN', 'Standard', 'Nationwide'),
('Saia LTL', 'SAIA', 'customerservice@saia.com', '1-800-SAIA-LTL', 'Standard', 'Nationwide'),
('Estes Express', 'ESTES', 'support@estes.com', '1-800-ESTES-EX', 'Standard, Express', 'Nationwide'),
('Yellow Corporation', 'YELLOW', 'service@yellow.com', '1-800-610-6500', 'Standard', 'Nationwide');

-- =============================================
-- INSERT CUSTOMERS
-- =============================================

INSERT INTO dbo.Customers (CustomerName, CustomerCode, Region, City, State, PostalCode, CustomerType, Industry) VALUES
('TechCorp Solutions', 'TECH01', 'West', 'Los Angeles', 'CA', '90210', 'Business', 'Technology'),
('Global Manufacturing Inc', 'GMI02', 'South', 'Houston', 'TX', '77001', 'Business', 'Manufacturing'),
('East Coast Distributors', 'ECD03', 'East', 'New York', 'NY', '10001', 'Business', 'Distribution'),
('Midwest Retail Group', 'MRG04', 'Midwest', 'Chicago', 'IL', '60601', 'Business', 'Retail'),
('Pacific Electronics', 'PEC05', 'West', 'Seattle', 'WA', '98101', 'Business', 'Electronics'),
('Southern Supply Chain', 'SSC06', 'South', 'Atlanta', 'GA', '30301', 'Business', 'Logistics'),
('Northeast Logistics', 'NEL07', 'East', 'Boston', 'MA', '02101', 'Business', 'Logistics'),
('Central Transport Co', 'CTC08', 'Midwest', 'Detroit', 'MI', '48201', 'Business', 'Transportation'),
('Western Distribution', 'WED09', 'West', 'Phoenix', 'AZ', '85001', 'Business', 'Distribution'),
('Atlantic Trading', 'ATT10', 'East', 'Miami', 'FL', '33101', 'Business', 'Trading'),
('Metro Manufacturing', 'MM11', 'Midwest', 'Cleveland', 'OH', '44101', 'Business', 'Manufacturing'),
('Coastal Electronics', 'CE12', 'West', 'San Francisco', 'CA', '94102', 'Business', 'Electronics'),
('Mountain Logistics', 'ML13', 'West', 'Denver', 'CO', '80201', 'Business', 'Logistics'),
('Gulf Coast Trading', 'GCT14', 'South', 'New Orleans', 'LA', '70112', 'Business', 'Trading'),
('Great Lakes Supply', 'GLS15', 'Midwest', 'Milwaukee', 'WI', '53201', 'Business', 'Supply Chain');

-- =============================================
-- INSERT ROUTES
-- =============================================

INSERT INTO dbo.Routes (OriginCity, OriginState, DestinationCity, DestinationState, DistanceMiles, EstimatedTransitDays, RouteType) VALUES
-- Major routes
('Los Angeles', 'CA', 'New York', 'NY', 2791, 5, 'Standard'),
('Los Angeles', 'CA', 'New York', 'NY', 2791, 2, 'Express'),
('Los Angeles', 'CA', 'New York', 'NY', 2791, 1, 'Overnight'),
('Houston', 'TX', 'Chicago', 'IL', 1089, 3, 'Standard'),
('Houston', 'TX', 'Chicago', 'IL', 1089, 1, 'Express'),
('New York', 'NY', 'Miami', 'FL', 1289, 3, 'Standard'),
('Chicago', 'IL', 'Seattle', 'WA', 2069, 4, 'Standard'),
('Seattle', 'WA', 'Phoenix', 'AZ', 1457, 3, 'Standard'),
('Atlanta', 'GA', 'Detroit', 'MI', 706, 2, 'Standard'),
('Boston', 'MA', 'Los Angeles', 'CA', 3012, 6, 'Standard'),
('Detroit', 'MI', 'Houston', 'TX', 1253, 4, 'Standard'),
('Phoenix', 'AZ', 'Boston', 'MA', 2357, 5, 'Standard'),
('Miami', 'FL', 'Seattle', 'WA', 2734, 6, 'Standard'),
('San Francisco', 'CA', 'Atlanta', 'GA', 2147, 5, 'Standard'),
('Denver', 'CO', 'Chicago', 'IL', 1003, 3, 'Standard'),
('Dallas', 'TX', 'Los Angeles', 'CA', 1435, 4, 'Standard'),
('Minneapolis', 'MN', 'Houston', 'TX', 1167, 4, 'Standard'),
('Portland', 'OR', 'Miami', 'FL', 3297, 7, 'Standard'),
('Las Vegas', 'NV', 'New York', 'NY', 2245, 5, 'Standard'),
('Orlando', 'FL', 'Seattle', 'WA', 2664, 6, 'Standard');

-- =============================================
-- INSERT SAMPLE SHIPMENTS (Last 12 months)
-- =============================================

DECLARE @StartDate DATE = DATEADD(MONTH, -12, GETDATE());
DECLARE @EndDate DATE = GETDATE();
DECLARE @CurrentDate DATE = @StartDate;
DECLARE @ShipmentCounter INT = 1;

WHILE @CurrentDate <= @EndDate
BEGIN
    -- Generate 8-15 shipments per day
    DECLARE @DailyShipmentCount INT = 8 + (ABS(CHECKSUM(NEWID())) % 8);
    DECLARE @Counter INT = 1;
    
    WHILE @Counter <= @DailyShipmentCount
    BEGIN
        DECLARE @CustomerID INT = 1 + (ABS(CHECKSUM(NEWID())) % 15);
        DECLARE @CarrierID INT = 1 + (ABS(CHECKSUM(NEWID())) % 10);
        DECLARE @RouteID INT = 1 + (ABS(CHECKSUM(NEWID())) % 20);
        DECLARE @ServiceLevel NVARCHAR(20);
        DECLARE @TransitDays INT;
        DECLARE @Weight DECIMAL(8,2) = 10 + (ABS(CHECKSUM(NEWID())) % 90);
        DECLARE @Volume DECIMAL(8,2) = 5 + (ABS(CHECKSUM(NEWID())) % 45);
        DECLARE @DeclaredValue DECIMAL(10,2) = 100 + (ABS(CHECKSUM(NEWID())) % 900);
        DECLARE @ShippingCost DECIMAL(10,2);
        DECLARE @InsuranceCost DECIMAL(10,2) = 0;
        DECLARE @FuelSurcharge DECIMAL(10,2) = 0;
        DECLARE @ActualDeliveryDate DATETIME2;
        DECLARE @Status NVARCHAR(20);
        DECLARE @IsOnTime BIT;
        
        -- Determine service level and pricing
        DECLARE @ServiceRandom INT = ABS(CHECKSUM(NEWID())) % 100;
        IF @ServiceRandom < 60
        BEGIN
            SET @ServiceLevel = 'Standard';
            SET @ShippingCost = 25 + (ABS(CHECKSUM(NEWID())) % 75);
            SET @TransitDays = 3 + (ABS(CHECKSUM(NEWID())) % 3);
        END
        ELSE IF @ServiceRandom < 85
        BEGIN
            SET @ServiceLevel = 'Express';
            SET @ShippingCost = 50 + (ABS(CHECKSUM(NEWID())) % 100);
            SET @TransitDays = 1 + (ABS(CHECKSUM(NEWID())) % 2);
            SET @FuelSurcharge = @ShippingCost * 0.15;
        END
        ELSE
        BEGIN
            SET @ServiceLevel = 'Overnight';
            SET @ShippingCost = 75 + (ABS(CHECKSUM(NEWID())) % 125);
            SET @TransitDays = 1;
            SET @FuelSurcharge = @ShippingCost * 0.20;
        END
        
        -- Add insurance for high-value items
        IF @DeclaredValue > 500
            SET @InsuranceCost = @DeclaredValue * 0.005;
        
        -- Determine delivery status (85% on-time delivery rate)
        DECLARE @DeliveryRandom INT = ABS(CHECKSUM(NEWID())) % 100;
        IF @DeliveryRandom < 85
        BEGIN
            SET @ActualDeliveryDate = DATEADD(DAY, @TransitDays, @CurrentDate);
            SET @Status = 'Delivered';
            SET @IsOnTime = 1;
        END
        ELSE IF @DeliveryRandom < 95
        BEGIN
            SET @ActualDeliveryDate = DATEADD(DAY, @TransitDays + 1 + (ABS(CHECKSUM(NEWID())) % 2), @CurrentDate);
            SET @Status = 'Delivered';
            SET @IsOnTime = 0;
        END
        ELSE IF @DeliveryRandom < 98
        BEGIN
            SET @ActualDeliveryDate = NULL;
            SET @Status = 'Exception';
            SET @IsOnTime = 0;
        END
        ELSE
        BEGIN
            SET @ActualDeliveryDate = NULL;
            SET @Status = 'In Transit';
            SET @IsOnTime = 0;
        END
        
        INSERT INTO dbo.Shipments (
            TrackingNumber, CustomerID, CarrierID, RouteID, ShipDate,
            EstimatedDeliveryDate, ActualDeliveryDate, Weight, Volume,
            DeclaredValue, ShippingCost, InsuranceCost, FuelSurcharge,
            ServiceLevel, Status
        )
        VALUES (
            'TRK' + RIGHT('000000' + CAST(@ShipmentCounter AS VARCHAR), 6),
            @CustomerID, @CarrierID, @RouteID, @CurrentDate,
            DATEADD(DAY, @TransitDays, @CurrentDate), @ActualDeliveryDate,
            @Weight, @Volume, @DeclaredValue, @ShippingCost,
            @InsuranceCost, @FuelSurcharge, @ServiceLevel, @Status
        );
        
        SET @Counter = @Counter + 1;
        SET @ShipmentCounter = @ShipmentCounter + 1;
    END
    
    SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);
END

-- =============================================
-- INSERT DELIVERY EXCEPTIONS
-- =============================================

-- Insert exceptions for shipments with 'Exception' status
INSERT INTO dbo.DeliveryExceptions (ShipmentID, ExceptionType, ExceptionDescription, ExceptionDate, ResolvedDate, ResolutionNotes, CostImpact, ResponsibleParty, Severity)
SELECT 
    s.ShipmentID,
    CASE ABS(CHECKSUM(NEWID())) % 6
        WHEN 0 THEN 'Damaged'
        WHEN 1 THEN 'Lost'
        WHEN 2 THEN 'Delayed'
        WHEN 3 THEN 'Weather'
        WHEN 4 THEN 'Address Issue'
        WHEN 5 THEN 'Customs'
    END as ExceptionType,
    CASE ABS(CHECKSUM(NEWID())) % 6
        WHEN 0 THEN 'Package arrived with visible damage to contents'
        WHEN 1 THEN 'Package not located at destination facility'
        WHEN 2 THEN 'Delivery delayed due to routing issues'
        WHEN 3 THEN 'Severe weather conditions preventing delivery'
        WHEN 4 THEN 'Incorrect or incomplete address provided'
        WHEN 5 THEN 'Customs clearance delay'
    END as ExceptionDescription,
    DATEADD(DAY, 1 + (ABS(CHECKSUM(NEWID())) % 3), s.ShipDate) as ExceptionDate,
    CASE 
        WHEN ABS(CHECKSUM(NEWID())) % 100 < 80 THEN
            DATEADD(DAY, 3 + (ABS(CHECKSUM(NEWID())) % 7), s.ShipDate)
        ELSE NULL
    END as ResolvedDate,
    CASE 
        WHEN ABS(CHECKSUM(NEWID())) % 100 < 80 THEN
            CASE ABS(CHECKSUM(NEWID())) % 4
                WHEN 0 THEN 'Issue resolved with customer satisfaction'
                WHEN 1 THEN 'Replacement shipment sent'
                WHEN 2 THEN 'Refund processed'
                WHEN 3 THEN 'Package recovered and delivered'
            END
        ELSE NULL
    END as ResolutionNotes,
    CASE ABS(CHECKSUM(NEWID())) % 5
        WHEN 0 THEN s.ShippingCost * 0.5 -- 50% of shipping cost
        WHEN 1 THEN s.DeclaredValue * 0.1 -- 10% of declared value
        WHEN 2 THEN s.ShippingCost * 0.2 -- 20% of shipping cost
        WHEN 3 THEN s.ShippingCost * 0.3 -- 30% of shipping cost
        WHEN 4 THEN s.ShippingCost * 0.1 -- 10% of shipping cost
    END as CostImpact,
    CASE ABS(CHECKSUM(NEWID())) % 3
        WHEN 0 THEN 'Carrier'
        WHEN 1 THEN 'Customer'
        WHEN 2 THEN 'Third Party'
    END as ResponsibleParty,
    CASE ABS(CHECKSUM(NEWID())) % 4
        WHEN 0 THEN 'Low'
        WHEN 1 THEN 'Medium'
        WHEN 2 THEN 'High'
        WHEN 3 THEN 'Critical'
    END as Severity
FROM dbo.Shipments s
WHERE s.Status = 'Exception' AND ABS(CHECKSUM(NEWID())) % 100 < 70; -- 70% of exception shipments get exception records

-- =============================================
-- DATA VALIDATION AND SUMMARY
-- =============================================

-- Display summary statistics
DECLARE @CarrierCount INT, @CustomerCount INT, @RouteCount INT, @ShipmentCount INT, @ExceptionCount INT;

SELECT @CarrierCount = COUNT(*) FROM dbo.Carriers;
SELECT @CustomerCount = COUNT(*) FROM dbo.Customers;
SELECT @RouteCount = COUNT(*) FROM dbo.Routes;
SELECT @ShipmentCount = COUNT(*) FROM dbo.Shipments;
SELECT @ExceptionCount = COUNT(*) FROM dbo.DeliveryExceptions;

PRINT '=============================================';
PRINT 'Sample Data Insertion Complete';
PRINT '=============================================';
PRINT 'Total Carriers: ' + CAST(@CarrierCount AS VARCHAR);
PRINT 'Total Customers: ' + CAST(@CustomerCount AS VARCHAR);
PRINT 'Total Routes: ' + CAST(@RouteCount AS VARCHAR);
PRINT 'Total Shipments: ' + CAST(@ShipmentCount AS VARCHAR);
PRINT 'Total Exceptions: ' + CAST(@ExceptionCount AS VARCHAR);

-- Calculate and display key KPIs
DECLARE @OnTimeRate DECIMAL(5,2), @AvgCost DECIMAL(10,2), @ExceptionRate DECIMAL(5,2);

SELECT @OnTimeRate = CAST(SUM(CASE WHEN ActualDeliveryDate <= EstimatedDeliveryDate THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2))
FROM dbo.Shipments 
WHERE ActualDeliveryDate IS NOT NULL;

SELECT @AvgCost = CAST(AVG(TotalCost) AS DECIMAL(10,2))
FROM dbo.Shipments;

SELECT @ExceptionRate = CAST(COUNT(e.ExceptionID) * 100.0 / COUNT(*) AS DECIMAL(5,2))
FROM dbo.Shipments s
LEFT JOIN dbo.DeliveryExceptions e ON s.ShipmentID = e.ShipmentID;

PRINT '';
PRINT 'Key Performance Indicators:';
PRINT 'On-Time Delivery Rate: ' + CAST(@OnTimeRate AS VARCHAR) + '%';
PRINT 'Average Cost per Shipment: $' + CAST(@AvgCost AS VARCHAR);
PRINT 'Exception Rate: ' + CAST(@ExceptionRate AS VARCHAR) + '%';
PRINT '=============================================';

PRINT '';
PRINT 'Sample data generation completed successfully!';
PRINT 'Ready for Power BI dashboard development.';
