# 🚀 Logistics KPI Dashboard - Setup Instructions

## Prerequisites

### Software Requirements
- **SQL Server 2016 or later** (Express, Standard, or Enterprise)
- **SQL Server Management Studio (SSMS)** or **Azure Data Studio**
- **Power BI Desktop** (Latest version recommended)
- **Power BI Service** (Optional, for cloud deployment)

### System Requirements
- **Windows 10/11** or **Windows Server 2016/2019/2022**
- **Minimum 8GB RAM** (16GB recommended for large datasets)
- **50GB free disk space** (for database and Power BI files)
- **Network access** to SQL Server instance

### Permissions Required
- **Database creation** permissions on SQL Server
- **Table creation** and **index creation** permissions
- **Power BI workspace** access (for cloud deployment)

## Installation Guide

### Step 1: SQL Server Database Setup

#### 1.1 Create Database Schema
```bash
# Method 1: Using sqlcmd (Command Line)
sqlcmd -S your_server_name -E -i 01-database-schema.sql

# Method 2: Using SSMS (Graphical Interface)
# 1. Open SSMS
# 2. Connect to your SQL Server instance
# 3. Open 01-database-schema.sql
# 4. Execute the script
```

#### 1.2 Populate Sample Data
```bash
# Method 1: Using sqlcmd (Command Line)
sqlcmd -S your_server_name -E -d LogisticsKPI -i 02-sample-data.sql

# Method 2: Using SSMS (Graphical Interface)
# 1. Switch to LogisticsKPI database
# 2. Open 02-sample-data.sql
# 3. Execute the script
```

#### 1.3 Verify Installation
```sql
-- Check database creation
SELECT name FROM sys.databases WHERE name = 'LogisticsKPI';

-- Check table creation
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'dbo' AND TABLE_TYPE = 'BASE TABLE';

-- Check data population
SELECT 
    'Carriers' as TableName, COUNT(*) as RecordCount FROM dbo.Carriers
UNION ALL
SELECT 'Customers', COUNT(*) FROM dbo.Customers
UNION ALL
SELECT 'Routes', COUNT(*) FROM dbo.Routes
UNION ALL
SELECT 'Shipments', COUNT(*) FROM dbo.Shipments
UNION ALL
SELECT 'DeliveryExceptions', COUNT(*) FROM dbo.DeliveryExceptions;
```

### Step 2: Test KPI Queries

#### 2.1 Run KPI Queries
```bash
# Execute KPI queries
sqlcmd -S your_server_name -E -d LogisticsKPI -i 03-kpi-queries.sql
```

#### 2.2 Verify Results
Expected results should show:
- **On-Time Delivery Rate**: ~61-65%
- **Average Cost per Shipment**: ~$70-75
- **Exception Rate**: ~8-10%
- **Total Shipments**: 4,000+

### Step 3: Power BI Setup

#### 3.1 Install Power BI Desktop
1. Download from [Microsoft Power BI Desktop](https://powerbi.microsoft.com/desktop/)
2. Install with default settings
3. Sign in with your Microsoft account

#### 3.2 Connect to Database
1. Open Power BI Desktop
2. Click **Get Data** → **SQL Server**
3. Enter server details:
   - **Server**: `your_server_name`
   - **Database**: `LogisticsKPI`
   - **Data Connectivity mode**: `DirectQuery` (recommended for real-time data)

#### 3.3 Import Tables
Import these tables in order:
1. **vw_ShipmentKPIs** (Main fact table)
2. **vw_DateTable** (Date dimension)
3. **Carriers** (Carrier dimension)
4. **Customers** (Customer dimension)
5. **Routes** (Route dimension)

#### 3.4 Set Up Relationships
Create these relationships:
- `vw_ShipmentKPIs[ShipDate]` → `vw_DateTable[Date]`
- `vw_ShipmentKPIs[CarrierID]` → `Carriers[CarrierID]`
- `vw_ShipmentKPIs[CustomerID]` → `Customers[CustomerID]`
- `vw_ShipmentKPIs[RouteID]` → `Routes[RouteID]`

#### 3.5 Add DAX Measures
1. Go to **Model** view
2. Click **New Measure**
3. Copy measures from `05-dax-measures.txt`
4. Create each measure individually

### Step 4: Dashboard Configuration

#### 4.1 Create Dashboard Pages
Follow the guide in `04-powerbi-dashboard.md` to create:
1. **Executive Summary** (Page 1)
2. **Carrier Performance** (Page 2)
3. **Exception Management** (Page 3)
4. **Customer Analytics** (Page 4)

#### 4.2 Configure Visualizations
For each page:
1. Add visualizations as specified in the guide
2. Configure conditional formatting
3. Set up slicers and filters
4. Test interactivity

#### 4.3 Set Up Alerts (Optional)
1. Go to Power BI Service
2. Create workspace
3. Publish dashboard
4. Configure alerts for KPIs

## Configuration Options

### Database Configuration

#### Connection String Examples
```sql
-- Windows Authentication
Server=localhost;Database=LogisticsKPI;Integrated Security=True;

-- SQL Server Authentication
Server=localhost;Database=LogisticsKPI;User Id=username;Password=password;

-- Named Instance
Server=localhost\SQLEXPRESS;Database=LogisticsKPI;Integrated Security=True;
```

#### Performance Tuning
```sql
-- Increase memory allocation (if needed)
ALTER SERVER CONFIGURATION SET MAX SERVER MEMORY (MB) = 8192;

-- Optimize database settings
ALTER DATABASE LogisticsKPI SET AUTO_UPDATE_STATISTICS ON;
ALTER DATABASE LogisticsKPI SET AUTO_CREATE_STATISTICS ON;
```

### Power BI Configuration

#### Data Source Settings
- **Refresh Schedule**: Every 4 hours (configurable)
- **Incremental Refresh**: Last 30 days for large datasets
- **DirectQuery**: For real-time data requirements
- **Import Mode**: For better performance with smaller datasets

#### Security Settings
```dax
// Row-Level Security Example
[Region Access] = 
USERNAME() IN {
    "region_west@company.com",
    "region_east@company.com",
    "region_midwest@company.com",
    "region_south@company.com"
}
```

## Troubleshooting

### Common Issues

#### Database Connection Issues
**Problem**: Cannot connect to SQL Server
**Solutions**:
1. Verify SQL Server service is running
2. Check firewall settings
3. Enable TCP/IP protocol
4. Verify authentication method

#### Data Import Issues
**Problem**: Power BI cannot import data
**Solutions**:
1. Check database permissions
2. Verify table names and schema
3. Test connection in SSMS first
4. Use DirectQuery mode for large datasets

#### Performance Issues
**Problem**: Slow dashboard performance
**Solutions**:
1. Optimize DAX measures
2. Use aggregations for large datasets
3. Implement incremental refresh
4. Consider Import mode for better performance

#### Missing Data Issues
**Problem**: No data showing in dashboard
**Solutions**:
1. Verify sample data was inserted
2. Check date filters
3. Verify relationships are correct
4. Refresh data source

### Error Messages

#### SQL Server Errors
```
Msg 208: Invalid object name
Solution: Verify database and table names exist

Msg 18456: Login failed
Solution: Check authentication credentials

Msg 262: CREATE DATABASE permission denied
Solution: Grant database creation permissions
```

#### Power BI Errors
```
"Could not connect to the server"
Solution: Verify server name and network connectivity

"No data was returned"
Solution: Check query syntax and data availability

"Relationship cannot be created"
Solution: Verify column data types match
```

## Performance Optimization

### Database Optimization
```sql
-- Update statistics
UPDATE STATISTICS dbo.Shipments;
UPDATE STATISTICS dbo.Carriers;
UPDATE STATISTICS dbo.Customers;

-- Rebuild indexes (if needed)
ALTER INDEX ALL ON dbo.Shipments REBUILD;
ALTER INDEX ALL ON dbo.Carriers REBUILD;
```

### Power BI Optimization
1. **Use DirectQuery** for real-time data
2. **Implement aggregations** for large datasets
3. **Optimize DAX measures** for better performance
4. **Use appropriate visual types** for data size

## Security Considerations

### Database Security
1. **Use Windows Authentication** when possible
2. **Create dedicated service accounts** for Power BI
3. **Implement row-level security** for multi-tenant scenarios
4. **Regular security updates** and patches

### Power BI Security
1. **Workspace permissions** and access control
2. **Row-level security** implementation
3. **Data sensitivity labels** for confidential data
4. **Audit logging** for compliance

## Backup and Recovery

### Database Backup
```sql
-- Full backup
BACKUP DATABASE LogisticsKPI 
TO DISK = 'C:\Backup\LogisticsKPI_Full.bak'
WITH FORMAT, INIT, NAME = 'LogisticsKPI Full Backup';

-- Transaction log backup
BACKUP LOG LogisticsKPI 
TO DISK = 'C:\Backup\LogisticsKPI_Log.trn';
```

### Power BI Backup
1. **Export .pbix files** regularly
2. **Document configurations** and customizations
3. **Backup workspace settings** and permissions
4. **Version control** for dashboard changes

## Maintenance Schedule

### Daily Tasks
- [ ] Verify data refresh completed successfully
- [ ] Check for any error alerts
- [ ] Monitor dashboard performance

### Weekly Tasks
- [ ] Review KPI trends and performance
- [ ] Update documentation if needed
- [ ] Check for Power BI updates

### Monthly Tasks
- [ ] Review user access and permissions
- [ ] Analyze performance metrics
- [ ] Plan dashboard enhancements

### Quarterly Tasks
- [ ] Security review and audit
- [ ] Performance optimization review
- [ ] User training and feedback collection

## Support Resources

### Documentation
- [Power BI Documentation](https://docs.microsoft.com/en-us/power-bi/)
- [SQL Server Documentation](https://docs.microsoft.com/en-us/sql/)
- [DAX Reference](https://docs.microsoft.com/en-us/dax/)

### Community Resources
- [Power BI Community](https://community.powerbi.com/)
- [SQL Server Community](https://docs.microsoft.com/en-us/answers/topics/sql-server.html)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/powerbi)

### Training Resources
- [Microsoft Learn](https://docs.microsoft.com/en-us/learn/)
- [Power BI Training](https://docs.microsoft.com/en-us/learn/powerplatform/power-bi)
- [SQL Server Training](https://docs.microsoft.com/en-us/learn/sql/)

---

**Setup Status**: Ready for deployment  
**Last Updated**: Current  
**Version**: 1.0  
**Estimated Setup Time**: 2-4 hours
