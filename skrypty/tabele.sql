USE [u_karcinsk]
GO
/****** Object:  Table [dbo].[AllPositions]    Script Date: 13.01.2023 15:32:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AllPositions](
	[PositionID] [int] NOT NULL,
	[PositionName] [varchar](255) NOT NULL,
	[UnitPrice] [money] NOT NULL,
	[LastActive] [datetime] NULL,
	[CategoryName] [varchar](255) NOT NULL,
 CONSTRAINT [pk_PositionID_AllPositions] PRIMARY KEY CLUSTERED 
(
	[PositionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Clients]    Script Date: 13.01.2023 15:32:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Clients](
	[ClientID] [int] NOT NULL,
 CONSTRAINT [pk_ClientID_Clients] PRIMARY KEY CLUSTERED 
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CompanyClients]    Script Date: 13.01.2023 15:32:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CompanyClients](
	[ClientID] [int] NOT NULL,
	[CompanyName] [varchar](255) NOT NULL,
	[Address] [varchar](255) NOT NULL,
	[Phone] [int] NOT NULL,
	[NIP] [bigint] NOT NULL,
 CONSTRAINT [pk_ClientID_CompanyClients] PRIMARY KEY CLUSTERED 
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Discounts]    Script Date: 13.01.2023 15:32:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Discounts](
	[ClientID] [int] NOT NULL,
	[D1] [bit] NOT NULL,
	[D2Used] [bit] NOT NULL,
	[D2LatestDate] [date] NULL,
 CONSTRAINT [pk_ClientID_Discounts] PRIMARY KEY CLUSTERED 
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Employees]    Script Date: 13.01.2023 15:32:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Employees](
	[EmployeeID] [int] NOT NULL,
	[FirstName] [varchar](255) NOT NULL,
	[LastName] [varchar](255) NOT NULL,
 CONSTRAINT [pk_EmployeeID_Employees] PRIMARY KEY CLUSTERED 
(
	[EmployeeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[IndividualClients]    Script Date: 13.01.2023 15:32:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IndividualClients](
	[ClientID] [int] NOT NULL,
	[FirstName] [varchar](255) NOT NULL,
	[LastName] [varchar](255) NOT NULL,
	[Phone] [int] NOT NULL,
	[NumOrders] [int] NOT NULL,
	[CompanyID] [int] NULL,
 CONSTRAINT [pk_ClientID_IndividualClients] PRIMARY KEY CLUSTERED 
(
	[ClientID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Menu]    Script Date: 13.01.2023 15:32:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Menu](
	[PositionID] [int] NOT NULL,
	[ActiveSince] [datetime] NULL,
 CONSTRAINT [pk_PositionID_Menu] PRIMARY KEY CLUSTERED 
(
	[PositionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[OrderDetails]    Script Date: 13.01.2023 15:32:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderDetails](
	[OrderID] [int] NULL,
	[PositionID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [money] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Orders]    Script Date: 13.01.2023 15:32:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Orders](
	[OrderID] [int] NOT NULL,
	[ClientID] [int] NOT NULL,
	[Discount] [float] NOT NULL,
	[OrderDate] [datetime] NOT NULL,
	[RealisationDate] [datetime] NULL,
	[ToGo] [bit] NOT NULL,
	[Accepted] [bit] NOT NULL,
	[EmployeeID] [int] NULL,
 CONSTRAINT [pk_OrderID_Orders] PRIMARY KEY CLUSTERED 
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PriceHistory]    Script Date: 13.01.2023 15:32:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PriceHistory](
	[PositionID] [int] NOT NULL,
	[UnitPrice] [money] NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
 CONSTRAINT [pk_PositionID_PriceHistory] PRIMARY KEY CLUSTERED 
(
	[PositionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[VarHistory]    Script Date: 13.01.2023 15:32:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[VarHistory](
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[Z1] [int] NULL,
	[K1] [int] NULL,
	[R1] [float] NULL,
	[K2] [int] NULL,
	[D1] [int] NULL,
	[R2] [float] NULL,
 CONSTRAINT [pk_StartDate_VarHistory] PRIMARY KEY CLUSTERED 
(
	[StartDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Variables]    Script Date: 13.01.2023 15:32:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Variables](
	[Z1] [int] NULL,
	[K1] [money] NULL,
	[R1] [float] NULL,
	[K2] [money] NULL,
	[D1] [int] NULL,
	[R2] [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CompanyClients]  WITH CHECK ADD  CONSTRAINT [fk_ClientID_CompanyClients] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ClientID])
GO
ALTER TABLE [dbo].[CompanyClients] CHECK CONSTRAINT [fk_ClientID_CompanyClients]
GO
ALTER TABLE [dbo].[Discounts]  WITH CHECK ADD  CONSTRAINT [fk_ClientID_Discounts] FOREIGN KEY([ClientID])
REFERENCES [dbo].[IndividualClients] ([ClientID])
GO
ALTER TABLE [dbo].[Discounts] CHECK CONSTRAINT [fk_ClientID_Discounts]
GO
ALTER TABLE [dbo].[IndividualClients]  WITH CHECK ADD  CONSTRAINT [fk_ClientID_IndividualClients] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ClientID])
GO
ALTER TABLE [dbo].[IndividualClients] CHECK CONSTRAINT [fk_ClientID_IndividualClients]
GO
ALTER TABLE [dbo].[IndividualClients]  WITH CHECK ADD  CONSTRAINT [fk_CompanyID_IndividualClients] FOREIGN KEY([CompanyID])
REFERENCES [dbo].[CompanyClients] ([ClientID])
GO
ALTER TABLE [dbo].[IndividualClients] CHECK CONSTRAINT [fk_CompanyID_IndividualClients]
GO
ALTER TABLE [dbo].[Menu]  WITH CHECK ADD  CONSTRAINT [fk_PositionID_Menu] FOREIGN KEY([PositionID])
REFERENCES [dbo].[AllPositions] ([PositionID])
GO
ALTER TABLE [dbo].[Menu] CHECK CONSTRAINT [fk_PositionID_Menu]
GO
ALTER TABLE [dbo].[OrderDetails]  WITH CHECK ADD  CONSTRAINT [fk_OrderID_OrderDetails] FOREIGN KEY([OrderID])
REFERENCES [dbo].[Orders] ([OrderID])
GO
ALTER TABLE [dbo].[OrderDetails] CHECK CONSTRAINT [fk_OrderID_OrderDetails]
GO
ALTER TABLE [dbo].[OrderDetails]  WITH CHECK ADD  CONSTRAINT [fk_PositionID_OrderDetails] FOREIGN KEY([PositionID])
REFERENCES [dbo].[AllPositions] ([PositionID])
GO
ALTER TABLE [dbo].[OrderDetails] CHECK CONSTRAINT [fk_PositionID_OrderDetails]
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [fk_ClientID_Orders] FOREIGN KEY([ClientID])
REFERENCES [dbo].[Clients] ([ClientID])
GO
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [fk_ClientID_Orders]
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [fk_EmployeeID_Orders] FOREIGN KEY([EmployeeID])
REFERENCES [dbo].[Employees] ([EmployeeID])
GO
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [fk_EmployeeID_Orders]
GO
ALTER TABLE [dbo].[PriceHistory]  WITH CHECK ADD  CONSTRAINT [fk_PositionID_PriceHistory] FOREIGN KEY([PositionID])
REFERENCES [dbo].[AllPositions] ([PositionID])
GO
ALTER TABLE [dbo].[PriceHistory] CHECK CONSTRAINT [fk_PositionID_PriceHistory]
GO
ALTER TABLE [dbo].[AllPositions]  WITH CHECK ADD  CONSTRAINT [Chk_Category] CHECK  (([CategoryName]='Napoj' OR [CategoryName]='Deser' OR [CategoryName]='Zupa' OR [CategoryName]='Owoce morza' OR [CategoryName]='Danie glowne'))
GO
ALTER TABLE [dbo].[AllPositions] CHECK CONSTRAINT [Chk_Category]
GO
ALTER TABLE [dbo].[AllPositions]  WITH CHECK ADD  CONSTRAINT [Chk_UnitPrice] CHECK  (([UnitPrice]>=(0)))
GO
ALTER TABLE [dbo].[AllPositions] CHECK CONSTRAINT [Chk_UnitPrice]
GO
ALTER TABLE [dbo].[CompanyClients]  WITH CHECK ADD  CONSTRAINT [Chk_NIP] CHECK  (([NIP]>=(1000000000) AND [NIP]<=(9999999999.)))
GO
ALTER TABLE [dbo].[CompanyClients] CHECK CONSTRAINT [Chk_NIP]
GO
ALTER TABLE [dbo].[CompanyClients]  WITH CHECK ADD  CONSTRAINT [Chk_Phone] CHECK  (([Phone]>=(100000000) AND [Phone]<=(999999999)))
GO
ALTER TABLE [dbo].[CompanyClients] CHECK CONSTRAINT [Chk_Phone]
GO
ALTER TABLE [dbo].[IndividualClients]  WITH CHECK ADD  CONSTRAINT [Chk_NumOrders] CHECK  (([NumOrders]>=(0)))
GO
ALTER TABLE [dbo].[IndividualClients] CHECK CONSTRAINT [Chk_NumOrders]
GO
ALTER TABLE [dbo].[IndividualClients]  WITH CHECK ADD  CONSTRAINT [Chk_Phone2] CHECK  (([Phone]>=(100000000) AND [Phone]<=(999999999)))
GO
ALTER TABLE [dbo].[IndividualClients] CHECK CONSTRAINT [Chk_Phone2]
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [Chk_Discount] CHECK  (([Discount]>=(0) AND [Discount]<=(1)))
GO
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [Chk_Discount]
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [Chk_OrderDateAndRealisationDate] CHECK  (([OrderDate]<=[RealisationDate]))
GO
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [Chk_OrderDateAndRealisationDate]
GO
ALTER TABLE [dbo].[PriceHistory]  WITH CHECK ADD  CONSTRAINT [Chk_Date] CHECK  (([EndDate] IS NULL OR [StartDate]<=[EndDate]))
GO
ALTER TABLE [dbo].[PriceHistory] CHECK CONSTRAINT [Chk_Date]
GO
ALTER TABLE [dbo].[PriceHistory]  WITH CHECK ADD  CONSTRAINT [Chk_UnitPrice2] CHECK  (([UnitPrice]>=(0)))
GO
ALTER TABLE [dbo].[PriceHistory] CHECK CONSTRAINT [Chk_UnitPrice2]
GO
ALTER TABLE [dbo].[VarHistory]  WITH CHECK ADD  CONSTRAINT [Chk_D1] CHECK  (([D1]>=(0)))
GO
ALTER TABLE [dbo].[VarHistory] CHECK CONSTRAINT [Chk_D1]
GO
ALTER TABLE [dbo].[VarHistory]  WITH CHECK ADD  CONSTRAINT [Chk_Date2] CHECK  (([EndDate] IS NULL OR [StartDate]<=[EndDate]))
GO
ALTER TABLE [dbo].[VarHistory] CHECK CONSTRAINT [Chk_Date2]
GO
ALTER TABLE [dbo].[VarHistory]  WITH CHECK ADD  CONSTRAINT [Chk_K1] CHECK  (([K1]>=(0)))
GO
ALTER TABLE [dbo].[VarHistory] CHECK CONSTRAINT [Chk_K1]
GO
ALTER TABLE [dbo].[VarHistory]  WITH CHECK ADD  CONSTRAINT [Chk_K2] CHECK  (([K2]>=(0)))
GO
ALTER TABLE [dbo].[VarHistory] CHECK CONSTRAINT [Chk_K2]
GO
ALTER TABLE [dbo].[VarHistory]  WITH CHECK ADD  CONSTRAINT [Chk_R1] CHECK  (([R1]>=(0) AND [R1]<=(1)))
GO
ALTER TABLE [dbo].[VarHistory] CHECK CONSTRAINT [Chk_R1]
GO
ALTER TABLE [dbo].[VarHistory]  WITH CHECK ADD  CONSTRAINT [Chk_R2] CHECK  (([R2]>=(0) AND [R2]<=(1)))
GO
ALTER TABLE [dbo].[VarHistory] CHECK CONSTRAINT [Chk_R2]
GO
ALTER TABLE [dbo].[VarHistory]  WITH CHECK ADD  CONSTRAINT [Chk_Z1] CHECK  (([Z1]>=(0)))
GO
ALTER TABLE [dbo].[VarHistory] CHECK CONSTRAINT [Chk_Z1]
GO
ALTER TABLE [dbo].[Variables]  WITH CHECK ADD  CONSTRAINT [Chk_CurrentD1] CHECK  (([D1]>=(0)))
GO
ALTER TABLE [dbo].[Variables] CHECK CONSTRAINT [Chk_CurrentD1]
GO
ALTER TABLE [dbo].[Variables]  WITH CHECK ADD  CONSTRAINT [Chk_CurrentK1] CHECK  (([K1]>=(0)))
GO
ALTER TABLE [dbo].[Variables] CHECK CONSTRAINT [Chk_CurrentK1]
GO
ALTER TABLE [dbo].[Variables]  WITH CHECK ADD  CONSTRAINT [Chk_CurrentK2] CHECK  (([K2]>=(0)))
GO
ALTER TABLE [dbo].[Variables] CHECK CONSTRAINT [Chk_CurrentK2]
GO
ALTER TABLE [dbo].[Variables]  WITH CHECK ADD  CONSTRAINT [Chk_CurrentR1] CHECK  (([R1]>=(0) AND [R1]<=(1)))
GO
ALTER TABLE [dbo].[Variables] CHECK CONSTRAINT [Chk_CurrentR1]
GO
ALTER TABLE [dbo].[Variables]  WITH CHECK ADD  CONSTRAINT [Chk_CurrentR2] CHECK  (([R2]>=(0) AND [R2]<=(1)))
GO
ALTER TABLE [dbo].[Variables] CHECK CONSTRAINT [Chk_CurrentR2]
GO
ALTER TABLE [dbo].[Variables]  WITH CHECK ADD  CONSTRAINT [Chk_CurrentZ1] CHECK  (([Z1]>=(0)))
GO
ALTER TABLE [dbo].[Variables] CHECK CONSTRAINT [Chk_CurrentZ1]
GO
