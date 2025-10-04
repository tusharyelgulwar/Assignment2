-- =============================================
-- Logistics KPI Dashboard - Optimized SQL Queries
-- =============================================
-- This script contains all the optimized SQL queries for calculating
-- logistics KPIs with proper indexing and performance optimization

USE LogisticsKPI;
GO

-- =============================================
-- 1. ON-TIME DELIVERY RATE KPI QUERIES
-- =============================================

-- Overall On-Time Delivery Rate
PRINT '=== OVERALL ON-TIME DELIVERY RATE ===';
SELECT 
    COUNT(*) as TotalShipments,
    SUM(CASE WHEN ActualDeliveryDate <= EstimatedDeliveryDate THEN 1 ELSE 0 END) as OnTimeShipments,
    CAST(SUM(CASE WHEN ActualDeliveryDate <= EstimatedDeliveryDate THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as OnTimeDeliveryRate,
    AVG(DATEDIFF(DAY, ShipDate, ActualDeliveryDate)) as AverageTransitDays,
    AVG(DATEDIFF(DAY, EstimatedDeliveryDate, ActualDeliveryDate)) as AverageDeliveryVariance
FROM dbo.Shipments 
WHERE ActualDeliveryDate IS NOT NULL;

-- On-Time Delivery Rate by Month (Last 12 months)
PRINT '=== ON-TIME DELIVERY RATE BY MONTH ===';
SELECT 
    YEAR(ShipDate) as Year,
    MONTH(ShipDate) as Month,
    DATENAME(MONTH, ShipDate) as MonthName,
    COUNT(*) as TotalShipments,
    SUM(CASE WHEN ActualDeliveryDate <= EstimatedDeliveryDate THEN 1 ELSE 0 END) as OnTimeShipments,
    CAST(SUM(CASE WHEN ActualDeliveryDate <= EstimatedDeliveryDate THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as OnTimeDeliveryRate,
    CAST(AVG(TotalCost) AS DECIMAL(10,2)) as AverageCost,
    SUM(TotalCost) as TotalRevenue
FROM dbo.Shipments 
WHERE ActualDeliveryDate IS NOT NULL
GROUP BY YEAR(ShipDate), MONTH(ShipDate), DATENAME(MONTH, ShipDate)
ORDER BY Year DESC, Month DESC;

-- On-Time Delivery Rate by Region
PRINT '=== ON-TIME DELIVERY RATE BY REGION ===';
SELECT 
    c.Region,
    COUNT(*) as TotalShipments,
    SUM(CASE WHEN s.ActualDeliveryDate <= s.EstimatedDeliveryDate THEN 1 ELSE 0 END) as OnTimeShipments,
    CAST(SUM(CASE WHEN s.ActualDeliveryDate <= s.EstimatedDeliveryDate THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as OnTimeDeliveryRate,
    CAST(AVG(s.TotalCost) AS DECIMAL(10,2)) as AverageCost,
    SUM(s.TotalCost) as TotalRevenue,
    AVG(DATEDIFF(DAY, s.ShipDate, s.ActualDeliveryDate)) as AverageTransitDays
FROM dbo.Shipments s
JOIN dbo.Customers c ON s.CustomerID = c.CustomerID
WHERE s.ActualDeliveryDate IS NOT NULL
GROUP BY c.Region
ORDER BY OnTimeDeliveryRate DESC;

-- On-Time Delivery Rate by Carrier
PRINT '=== ON-TIME DELIVERY RATE BY CARRIER ===';
SELECT 
    car.CarrierName,
    car.CarrierCode,
    COUNT(*) as TotalShipments,
    SUM(CASE WHEN s.ActualDeliveryDate <= s.EstimatedDeliveryDate THEN 1 ELSE 0 END) as OnTimeShipments,
    CAST(SUM(CASE WHEN s.ActualDeliveryDate <= s.EstimatedDeliveryDate THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as OnTimeDeliveryRate,
    CAST(AVG(s.TotalCost) AS DECIMAL(10,2)) as AverageCost,
    SUM(s.TotalCost) as TotalRevenue,
    COUNT(DISTINCT s.CustomerID) as UniqueCustomers
FROM dbo.Shipments s
JOIN dbo.Carriers car ON s.CarrierID = car.CarrierID
WHERE s.ActualDeliveryDate IS NOT NULL
GROUP BY car.CarrierName, car.CarrierCode
ORDER BY OnTimeDeliveryRate DESC;

-- On-Time Delivery Rate by Service Level
PRINT '=== ON-TIME DELIVERY RATE BY SERVICE LEVEL ===';
SELECT 
    ServiceLevel,
    COUNT(*) as TotalShipments,
    SUM(CASE WHEN ActualDeliveryDate <= EstimatedDeliveryDate THEN 1 ELSE 0 END) as OnTimeShipments,
    CAST(SUM(CASE WHEN ActualDeliveryDate <= EstimatedDeliveryDate THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as OnTimeDeliveryRate,
    CAST(AVG(TotalCost) AS DECIMAL(10,2)) as AverageCost,
    AVG(DATEDIFF(DAY, ShipDate, ActualDeliveryDate)) as AverageTransitDays
FROM dbo.Shipments 
WHERE ActualDeliveryDate IS NOT NULL
GROUP BY ServiceLevel
ORDER BY OnTimeDeliveryRate DESC;

-- =============================================
-- 2. COST ANALYSIS KPI QUERIES
-- =============================================

-- Overall Cost Analysis
PRINT '=== OVERALL COST ANALYSIS ===';
SELECT 
    COUNT(*) as TotalShipments,
    SUM(TotalCost) as TotalShippingCost,
    CAST(AVG(TotalCost) AS DECIMAL(10,2)) as AverageCostPerShipment,
    CAST(AVG(ShippingCost) AS DECIMAL(10,2)) as AverageBaseShippingCost,
    CAST(AVG(InsuranceCost) AS DECIMAL(10,2)) as AverageInsuranceCost,
    CAST(AVG(FuelSurcharge) AS DECIMAL(10,2)) as AverageFuelSurcharge,
    SUM(Weight) as TotalWeightShipped,
    SUM(Volume) as TotalVolumeShipped
FROM dbo.Shipments;

-- Cost Analysis by Month
PRINT '=== COST ANALYSIS BY MONTH ===';
SELECT 
    YEAR(ShipDate) as Year,
    MONTH(ShipDate) as Month,
    DATENAME(MONTH, ShipDate) as MonthName,
    COUNT(*) as TotalShipments,
    SUM(TotalCost) as TotalShippingCost,
    CAST(AVG(TotalCost) AS DECIMAL(10,2)) as AverageCostPerShipment,
    SUM(Weight) as TotalWeightShipped,
    CAST(SUM(TotalCost) / SUM(Weight) AS DECIMAL(10,4)) as CostPerPound
FROM dbo.Shipments 
GROUP BY YEAR(ShipDate), MONTH(ShipDate), DATENAME(MONTH, ShipDate)
ORDER BY Year DESC, Month DESC;

-- Cost Analysis by Carrier
PRINT '=== COST ANALYSIS BY CARRIER ===';
SELECT 
    car.CarrierName,
    car.CarrierCode,
    COUNT(*) as TotalShipments,
    SUM(s.TotalCost) as TotalRevenue,
    CAST(AVG(s.TotalCost) AS DECIMAL(10,2)) as AverageCostPerShipment,
    CAST(AVG(s.ShippingCost) AS DECIMAL(10,2)) as AverageBaseCost,
    CAST(AVG(s.FuelSurcharge) AS DECIMAL(10,2)) as AverageFuelSurcharge,
    SUM(s.Weight) as TotalWeightShipped,
    CAST(SUM(s.TotalCost) / SUM(s.Weight) AS DECIMAL(10,4)) as CostPerPound
FROM dbo.Shipments s
JOIN dbo.Carriers car ON s.CarrierID = car.CarrierID
GROUP BY car.CarrierName, car.CarrierCode
ORDER BY AverageCostPerShipment ASC;

-- Cost Analysis by Region
PRINT '=== COST ANALYSIS BY REGION ===';
SELECT 
    c.Region,
    COUNT(*) as TotalShipments,
    SUM(s.TotalCost) as TotalShippingCost,
    CAST(AVG(s.TotalCost) AS DECIMAL(10,2)) as AverageCostPerShipment,
    SUM(s.Weight) as TotalWeightShipped,
    CAST(SUM(s.TotalCost) / SUM(s.Weight) AS DECIMAL(10,4)) as CostPerPound,
    AVG(rt.DistanceMiles) as AverageDistance
FROM dbo.Shipments s
JOIN dbo.Customers c ON s.CustomerID = c.CustomerID
JOIN dbo.Routes rt ON s.RouteID = rt.RouteID
GROUP BY c.Region
ORDER BY AverageCostPerShipment DESC;

-- =============================================
-- 3. CARRIER PERFORMANCE ANALYSIS QUERIES
-- =============================================

-- Comprehensive Carrier Performance Dashboard
PRINT '=== COMPREHENSIVE CARRIER PERFORMANCE ===';
SELECT 
    car.CarrierName,
    car.CarrierCode,
    COUNT(*) as TotalShipments,
    SUM(CASE WHEN s.ActualDeliveryDate <= s.EstimatedDeliveryDate THEN 1 ELSE 0 END) as OnTimeDeliveries,
    CAST(SUM(CASE WHEN s.ActualDeliveryDate <= s.EstimatedDeliveryDate THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as OnTimeDeliveryRate,
    CAST(AVG(s.TotalCost) AS DECIMAL(10,2)) as AverageShippingCost,
    SUM(s.TotalCost) as TotalRevenue,
    COUNT(DISTINCT s.CustomerID) as UniqueCustomers,
    AVG(DATEDIFF(DAY, s.ShipDate, s.ActualDeliveryDate)) as AverageTransitDays,
    CAST(AVG(s.Weight) AS DECIMAL(8,2)) as AveragePackageWeight,
    COUNT(e.ExceptionID) as TotalExceptions,
    CAST(COUNT(e.ExceptionID) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as ExceptionRate
FROM dbo.Shipments s
JOIN dbo.Carriers car ON s.CarrierID = car.CarrierID
LEFT JOIN dbo.DeliveryExceptions e ON s.ShipmentID = e.ShipmentID
WHERE s.ActualDeliveryDate IS NOT NULL
GROUP BY car.CarrierName, car.CarrierCode
ORDER BY OnTimeDeliveryRate DESC, AverageShippingCost ASC;

-- Carrier Performance by Service Level
PRINT '=== CARRIER PERFORMANCE BY SERVICE LEVEL ===';
SELECT 
    car.CarrierName,
    s.ServiceLevel,
    COUNT(*) as TotalShipments,
    SUM(CASE WHEN s.ActualDeliveryDate <= s.EstimatedDeliveryDate THEN 1 ELSE 0 END) as OnTimeDeliveries,
    CAST(SUM(CASE WHEN s.ActualDeliveryDate <= s.EstimatedDeliveryDate THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as OnTimeDeliveryRate,
    CAST(AVG(s.TotalCost) AS DECIMAL(10,2)) as AverageShippingCost,
    AVG(DATEDIFF(DAY, s.ShipDate, s.ActualDeliveryDate)) as AverageTransitDays
FROM dbo.Shipments s
JOIN dbo.Carriers car ON s.CarrierID = car.CarrierID
WHERE s.ActualDeliveryDate IS NOT NULL
GROUP BY car.CarrierName, s.ServiceLevel
ORDER BY car.CarrierName, s.ServiceLevel;

-- Carrier Performance Trends (Monthly)
PRINT '=== CARRIER PERFORMANCE TRENDS ===';
SELECT 
    car.CarrierName,
    YEAR(s.ShipDate) as Year,
    MONTH(s.ShipDate) as Month,
    DATENAME(MONTH, s.ShipDate) as MonthName,
    COUNT(*) as TotalShipments,
    CAST(SUM(CASE WHEN s.ActualDeliveryDate <= s.EstimatedDeliveryDate THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as OnTimeDeliveryRate,
    CAST(AVG(s.TotalCost) AS DECIMAL(10,2)) as AverageCost,
    SUM(s.TotalCost) as TotalRevenue
FROM dbo.Shipments s
JOIN dbo.Carriers car ON s.CarrierID = car.CarrierID
WHERE s.ActualDeliveryDate IS NOT NULL
GROUP BY car.CarrierName, YEAR(s.ShipDate), MONTH(s.ShipDate), DATENAME(MONTH, s.ShipDate)
ORDER BY car.CarrierName, Year DESC, Month DESC;

-- =============================================
-- 4. DELIVERY EXCEPTIONS ANALYSIS QUERIES
-- =============================================

-- Overall Exception Rate
PRINT '=== OVERALL EXCEPTION ANALYSIS ===';
SELECT 
    COUNT(*) as TotalShipments,
    COUNT(e.ExceptionID) as TotalExceptions,
    CAST(COUNT(e.ExceptionID) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as ExceptionRate,
    SUM(ISNULL(e.CostImpact, 0)) as TotalExceptionCost,
    CAST(AVG(ISNULL(e.CostImpact, 0)) AS DECIMAL(10,2)) as AverageExceptionCost
FROM dbo.Shipments s
LEFT JOIN dbo.DeliveryExceptions e ON s.ShipmentID = e.ShipmentID;

-- Exception Rate by Month
PRINT '=== EXCEPTION RATE BY MONTH ===';
SELECT 
    YEAR(s.ShipDate) as Year,
    MONTH(s.ShipDate) as Month,
    DATENAME(MONTH, s.ShipDate) as MonthName,
    COUNT(*) as TotalShipments,
    COUNT(e.ExceptionID) as TotalExceptions,
    CAST(COUNT(e.ExceptionID) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as ExceptionRate,
    SUM(ISNULL(e.CostImpact, 0)) as TotalExceptionCost,
    COUNT(CASE WHEN e.ResolvedDate IS NOT NULL THEN 1 END) as ResolvedExceptions,
    CAST(COUNT(CASE WHEN e.ResolvedDate IS NOT NULL THEN 1 END) * 100.0 / COUNT(e.ExceptionID) AS DECIMAL(5,2)) as ResolutionRate
FROM dbo.Shipments s
LEFT JOIN dbo.DeliveryExceptions e ON s.ShipmentID = e.ShipmentID
GROUP BY YEAR(s.ShipDate), MONTH(s.ShipDate), DATENAME(MONTH, s.ShipDate)
ORDER BY Year DESC, Month DESC;

-- Exception Types Analysis
PRINT '=== EXCEPTION TYPES ANALYSIS ===';
SELECT 
    e.ExceptionType,
    COUNT(*) as ExceptionCount,
    CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM dbo.DeliveryExceptions) AS DECIMAL(5,2)) as PercentageOfExceptions,
    SUM(e.CostImpact) as TotalCostImpact,
    CAST(AVG(e.CostImpact) AS DECIMAL(10,2)) as AverageCostImpact,
    COUNT(CASE WHEN e.ResolvedDate IS NOT NULL THEN 1 END) as ResolvedExceptions,
    CAST(COUNT(CASE WHEN e.ResolvedDate IS NOT NULL THEN 1 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as ResolutionRate,
    AVG(DATEDIFF(DAY, e.ExceptionDate, ISNULL(e.ResolvedDate, GETDATE()))) as AverageResolutionDays
FROM dbo.DeliveryExceptions e
GROUP BY e.ExceptionType
ORDER BY ExceptionCount DESC;

-- Exception Rate by Carrier
PRINT '=== EXCEPTION RATE BY CARRIER ===';
SELECT 
    car.CarrierName,
    car.CarrierCode,
    COUNT(s.ShipmentID) as TotalShipments,
    COUNT(e.ExceptionID) as TotalExceptions,
    CAST(COUNT(e.ExceptionID) * 100.0 / COUNT(s.ShipmentID) AS DECIMAL(5,2)) as ExceptionRate,
    SUM(ISNULL(e.CostImpact, 0)) as TotalExceptionCost,
    CAST(AVG(ISNULL(e.CostImpact, 0)) AS DECIMAL(10,2)) as AverageExceptionCost,
    COUNT(CASE WHEN e.ResolvedDate IS NOT NULL THEN 1 END) as ResolvedExceptions,
    CAST(COUNT(CASE WHEN e.ResolvedDate IS NOT NULL THEN 1 END) * 100.0 / COUNT(e.ExceptionID) AS DECIMAL(5,2)) as ResolutionRate
FROM dbo.Shipments s
JOIN dbo.Carriers car ON s.CarrierID = car.CarrierID
LEFT JOIN dbo.DeliveryExceptions e ON s.ShipmentID = e.ShipmentID
GROUP BY car.CarrierName, car.CarrierCode
ORDER BY ExceptionRate DESC;

-- Exception Rate by Region
PRINT '=== EXCEPTION RATE BY REGION ===';
SELECT 
    c.Region,
    COUNT(s.ShipmentID) as TotalShipments,
    COUNT(e.ExceptionID) as TotalExceptions,
    CAST(COUNT(e.ExceptionID) * 100.0 / COUNT(s.ShipmentID) AS DECIMAL(5,2)) as ExceptionRate,
    SUM(ISNULL(e.CostImpact, 0)) as TotalExceptionCost,
    AVG(ISNULL(e.CostImpact, 0)) as AverageExceptionCost
FROM dbo.Shipments s
JOIN dbo.Customers c ON s.CustomerID = c.CustomerID
LEFT JOIN dbo.DeliveryExceptions e ON s.ShipmentID = e.ShipmentID
GROUP BY c.Region
ORDER BY ExceptionRate DESC;

-- Exception Severity Analysis
PRINT '=== EXCEPTION SEVERITY ANALYSIS ===';
SELECT 
    e.Severity,
    COUNT(*) as ExceptionCount,
    CAST(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM dbo.DeliveryExceptions) AS DECIMAL(5,2)) as PercentageOfExceptions,
    SUM(e.CostImpact) as TotalCostImpact,
    CAST(AVG(e.CostImpact) AS DECIMAL(10,2)) as AverageCostImpact,
    COUNT(CASE WHEN e.ResolvedDate IS NOT NULL THEN 1 END) as ResolvedExceptions,
    CAST(COUNT(CASE WHEN e.ResolvedDate IS NOT NULL THEN 1 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as ResolutionRate
FROM dbo.DeliveryExceptions e
GROUP BY e.Severity
ORDER BY 
    CASE e.Severity
        WHEN 'Critical' THEN 1
        WHEN 'High' THEN 2
        WHEN 'Medium' THEN 3
        WHEN 'Low' THEN 4
    END;

-- =============================================
-- 5. COMPREHENSIVE KPI DASHBOARD QUERY
-- =============================================

-- Master KPI Dashboard - All Key Metrics
PRINT '=== MASTER KPI DASHBOARD ===';
WITH MonthlyKPIs AS (
    SELECT 
        YEAR(s.ShipDate) as Year,
        MONTH(s.ShipDate) as Month,
        DATENAME(MONTH, s.ShipDate) as MonthName,
        COUNT(*) as TotalShipments,
        SUM(s.TotalCost) as TotalShippingCost,
        CAST(AVG(s.TotalCost) AS DECIMAL(10,2)) as AverageCostPerShipment,
        SUM(CASE WHEN s.ActualDeliveryDate <= s.EstimatedDeliveryDate THEN 1 ELSE 0 END) as OnTimeDeliveries,
        CAST(SUM(CASE WHEN s.ActualDeliveryDate <= s.EstimatedDeliveryDate THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as OnTimeDeliveryRate,
        COUNT(e.ExceptionID) as TotalExceptions,
        CAST(COUNT(e.ExceptionID) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as ExceptionRate,
        SUM(ISNULL(e.CostImpact, 0)) as TotalExceptionCost,
        AVG(DATEDIFF(DAY, s.ShipDate, s.ActualDeliveryDate)) as AverageTransitDays
    FROM dbo.Shipments s
    LEFT JOIN dbo.DeliveryExceptions e ON s.ShipmentID = e.ShipmentID
    WHERE s.ActualDeliveryDate IS NOT NULL
    GROUP BY YEAR(s.ShipDate), MONTH(s.ShipDate), DATENAME(MONTH, s.ShipDate)
)
SELECT 
    Year,
    Month,
    MonthName,
    TotalShipments,
    TotalShippingCost,
    AverageCostPerShipment,
    OnTimeDeliveries,
    OnTimeDeliveryRate,
    TotalExceptions,
    ExceptionRate,
    TotalExceptionCost,
    (TotalShippingCost + TotalExceptionCost) as TotalCostWithExceptions,
    AverageTransitDays
FROM MonthlyKPIs
ORDER BY Year DESC, Month DESC;

-- =============================================
-- 6. PERFORMANCE BENCHMARKS
-- =============================================

-- Performance Benchmarks and Targets
PRINT '=== PERFORMANCE BENCHMARKS ===';
SELECT 
    'Overall Performance' as MetricCategory,
    'On-Time Delivery Rate' as MetricName,
    CAST(SUM(CASE WHEN ActualDeliveryDate <= EstimatedDeliveryDate THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as CurrentValue,
    95.0 as TargetValue,
    CASE 
        WHEN CAST(SUM(CASE WHEN ActualDeliveryDate <= EstimatedDeliveryDate THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) >= 95.0 THEN 'Target Met'
        WHEN CAST(SUM(CASE WHEN ActualDeliveryDate <= EstimatedDeliveryDate THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) >= 90.0 THEN 'Above Average'
        WHEN CAST(SUM(CASE WHEN ActualDeliveryDate <= EstimatedDeliveryDate THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) >= 85.0 THEN 'Average'
        ELSE 'Below Average'
    END as PerformanceStatus
FROM dbo.Shipments 
WHERE ActualDeliveryDate IS NOT NULL

UNION ALL

SELECT 
    'Overall Performance' as MetricCategory,
    'Exception Rate' as MetricName,
    CAST(COUNT(e.ExceptionID) * 100.0 / COUNT(*) AS DECIMAL(5,2)) as CurrentValue,
    5.0 as TargetValue,
    CASE 
        WHEN CAST(COUNT(e.ExceptionID) * 100.0 / COUNT(*) AS DECIMAL(5,2)) <= 5.0 THEN 'Target Met'
        WHEN CAST(COUNT(e.ExceptionID) * 100.0 / COUNT(*) AS DECIMAL(5,2)) <= 8.0 THEN 'Above Average'
        WHEN CAST(COUNT(e.ExceptionID) * 100.0 / COUNT(*) AS DECIMAL(5,2)) <= 12.0 THEN 'Average'
        ELSE 'Below Average'
    END as PerformanceStatus
FROM dbo.Shipments s
LEFT JOIN dbo.DeliveryExceptions e ON s.ShipmentID = e.ShipmentID

UNION ALL

SELECT 
    'Cost Performance' as MetricCategory,
    'Average Cost per Shipment' as MetricName,
    CAST(AVG(TotalCost) AS DECIMAL(10,2)) as CurrentValue,
    75.0 as TargetValue,
    CASE 
        WHEN CAST(AVG(TotalCost) AS DECIMAL(10,2)) <= 75.0 THEN 'Target Met'
        WHEN CAST(AVG(TotalCost) AS DECIMAL(10,2)) <= 85.0 THEN 'Above Average'
        WHEN CAST(AVG(TotalCost) AS DECIMAL(10,2)) <= 95.0 THEN 'Average'
        ELSE 'Below Average'
    END as PerformanceStatus
FROM dbo.Shipments;

PRINT '=============================================';
PRINT 'All KPI queries executed successfully!';
PRINT 'Ready for Power BI dashboard integration.';
PRINT '=============================================';
