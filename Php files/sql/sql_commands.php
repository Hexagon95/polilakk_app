<?php
class SqlCommand{
    // ---------- <Constructor> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    function __Construct(){}

    // ---------- <SQL Scripts> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    public function select_termelesFolyamat1()	            {return "SELECT * FROM [dbo].[Termeles_folyamat1] ()";}
    public function select_termelesFolyamat1a()	            {return "SELECT b FROM [dbo].[Termeles_folyamat1a] ()";}
    public function select_termelesFolyamat2()	            {return "SELECT * FROM [dbo].[Termeles_folyamat2] ()";}
    public function select_termelesFolyamat3()	            {return "SELECT * FROM [dbo].[Termeles_folyamat3] ()";}
    public function select_termelesFolyamat4()	            {return "SELECT * FROM [dbo].[Termeles_folyamat4] ()";}
    public function select_termelesFolyamat5()	            {return "SELECT * FROM [dbo].[Termeles_folyamat5] ()";}
    public function select_termelesFolyamat6()	            {return "SELECT * FROM [dbo].[Termeles_folyamat6] ()";}
    public function select_termelesFolyamat2Gerenda()       {return "SELECT b FROM [dbo].[Termeles_folyamat2_gerenda] ()";}
    public function select_termelesFolyamat5Kaloda()        {return "SELECT * FROM [dbo].[Termeles_folyamat5_kaloda] (:vedofoliazas, :gorgozes)";}
    public function select_termelesFolyamat6Kaloda()        {return "SELECT * FROM [dbo].[Termeles_folyamat6_kaloda] (:gorgozes)";}
    public function select_termelesKosar()	                {return "SELECT b FROM [dbo].[Termeles_kosar] ()";}
    public function select_termelesFolyamat5KalodaZarni()   {return "SELECT b FROM [dbo].[Termeles_folyamat5_kaloda_zarni] ()";}
    public function select_termelesFolyamat6KalodaZarni()   {return "SELECT b FROM [dbo].[Termeles_folyamat6_kaloda_zarni] ()";}
    public function select_termelesFolyamat5KalodaCimke()   {return "SELECT b FROM [dbo].[Termeles_folyamat5_kaloda_cimke] (:id)";}
    public function select_termelesFolyamat6KalodaCimke()   {return "SELECT b FROM [dbo].[Termeles_folyamat6_kaloda_cimke] (:id)";}
    public function select_verzio()                         {return "SELECT verzio_koat_app FROM [dbo].[Parameters]";}
    public function exec_termelesFolyamat1Felvitele()       {return "EXEC [dbo].[Termeles_folyamat1_felvitele] :parameter, :output";}
    public function exec_termelesFolyamat1aFelvitele()      {return "EXEC [dbo].[Termeles_folyamat1a_felvitele] :parameter, :output";}
    public function exec_termelesFolyamat2Felvitele()       {return "EXEC [dbo].[Termeles_folyamat2_felvitele] :parameter, :output";}
    public function exec_termelesFolyamat3Felvitele()       {return "EXEC [dbo].[Termeles_folyamat3_felvitele] :parameter, :output";}
    public function exec_termelesFolyamat4Felvitele()       {return "EXEC [dbo].[Termeles_folyamat4_felvitele] :parameter, :output";}
    public function exec_termelesFolyamat5Felvitele()       {return "EXEC [dbo].[Termeles_folyamat5_felvitele] :parameter, :output";}
    public function exec_termelesFolyamat6Felvitele()       {return "EXEC [dbo].[Termeles_folyamat6_felvitele] :parameter, :output";}
    public function exec_termelesKosarZaras()               {return "EXEC [dbo].[Termeles_kosar_zaras] :id, :user_id, :output";}
    public function exec_termeles2GerendaZaras()            {return "EXEC [dbo].[Termeles2_gerenda_zaras] :id, :user_id, :output";}
    public function exec_termeles5KalodaFelvitel()          {return "EXEC [dbo].[Termeles5_kaloda_felvitel] :input1, :input2, :id, :outputid, :output";}
    public function exec_termeles6KalodaFelvitel()          {return "EXEC [dbo].[Termeles6_kaloda_felvitel] :input1, :id, :outputid, :output";}
    public function exec_termeles5KalodaZaras()             {return "EXEC [dbo].[Termeles5_kaloda_zaras] :id, :user_id, :output";}
    public function exec_termeles6KalodaZaras()             {return "EXEC [dbo].[Termeles6_kaloda_zaras] :id, :user_id, :output";}
    public function exec_barcodePrint()                     {return "EXEC [dbo].[BarcodePrint] :parameter, :output";}
    public function exec_barcodePrintFelvitel()             {return "EXEC [dbo].[Barcode_print_Felvitele] :zpl_kod, :folyamat_id, :ip";}
}