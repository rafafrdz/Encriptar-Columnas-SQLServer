USE [master]
GO
CREATE DATABASE [EncriptarColumnas]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'EncriptarColumnas', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.DBENGINE\MSSQL\DATA\EncriptarColumnas.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'EncriptarColumnas_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.DBENGINE\MSSQL\DATA\EncriptarColumnas_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO

ALTER DATABASE [EncriptarColumnas] SET COMPATIBILITY_LEVEL = 140
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [EncriptarColumnas].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

ALTER DATABASE [EncriptarColumnas] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [EncriptarColumnas] SET ANSI_NULLS OFF 
GO

ALTER DATABASE [EncriptarColumnas] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [EncriptarColumnas] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [EncriptarColumnas] SET ARITHABORT OFF 
GO

ALTER DATABASE [EncriptarColumnas] SET AUTO_CLOSE OFF 
GO

ALTER DATABASE [EncriptarColumnas] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [EncriptarColumnas] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [EncriptarColumnas] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [EncriptarColumnas] SET CURSOR_DEFAULT  GLOBAL 
GO

ALTER DATABASE [EncriptarColumnas] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [EncriptarColumnas] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [EncriptarColumnas] SET QUOTED_IDENTIFIER OFF 
GO

ALTER DATABASE [EncriptarColumnas] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [EncriptarColumnas] SET  DISABLE_BROKER 
GO

ALTER DATABASE [EncriptarColumnas] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [EncriptarColumnas] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [EncriptarColumnas] SET TRUSTWORTHY OFF 
GO

ALTER DATABASE [EncriptarColumnas] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO

ALTER DATABASE [EncriptarColumnas] SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [EncriptarColumnas] SET READ_COMMITTED_SNAPSHOT OFF 
GO

ALTER DATABASE [EncriptarColumnas] SET HONOR_BROKER_PRIORITY OFF 
GO

ALTER DATABASE [EncriptarColumnas] SET RECOVERY FULL 
GO

ALTER DATABASE [EncriptarColumnas] SET  MULTI_USER 
GO

ALTER DATABASE [EncriptarColumnas] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [EncriptarColumnas] SET DB_CHAINING OFF 
GO

ALTER DATABASE [EncriptarColumnas] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO

ALTER DATABASE [EncriptarColumnas] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO

ALTER DATABASE [EncriptarColumnas] SET DELAYED_DURABILITY = DISABLED 
GO

ALTER DATABASE [EncriptarColumnas] SET QUERY_STORE = OFF
GO

ALTER DATABASE [EncriptarColumnas] SET  READ_WRITE 
GO


