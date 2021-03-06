//+------------------------------------------------------------------+
//|                                                    LinearReg.mq5 |
//|                                                       Rodrigo S. |
//|                                            rodrigosf@outlook.com |
//+------------------------------------------------------------------+
#property copyright "Rodrigo S."
#property link      "rodrigosf@outlook.com"
#property version   "1.00"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_type1   DRAW_ARROW
#property indicator_color1  LightSeaGreen
#property indicator_label1  "Middle reg linear"

input int Periodo = 200;

double buffer[];

int OnInit()
{
   SetIndexBuffer(0, buffer);
   PlotIndexSetInteger(0, PLOT_ARROW, 159); 
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0); 

   IndicatorSetString(INDICATOR_SHORTNAME, "Linear Regression FX");
   
   return(INIT_SUCCEEDED);
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
{

   double vVlEsq = 0,
          vVlDir = 0;

   int pos = 0;

   if(rates_total<=Periodo) return(0);

   if(prev_calculated>1) 
      pos = prev_calculated-1;
   else 
      pos = 0;   

   for(int i=pos;i<rates_total && !IsStopped();i++)
   {
      LinearReg_Func(price, i, Periodo, vVlEsq, vVlDir);
      buffer[i] = NormalizeDouble(vVlDir, _Digits);
   }

   return(rates_total);
}

void LinearReg_Func(
                     const double &price[],
                     int pIndiceBarra,
                     int pPeriodo, 
                     double &pVlrEsq, 
                     double &pVlrDir)
{

   double a     = 0,
          b     = 0,
          c     = 0,
          sumy  = 0,
          sumx  = 0,
          sumxy = 0,
          sumx2 = 0;
          
   int i = 0, 
       x = 0;

   pVlrEsq = 0;
   pVlrDir = 0;

   x = 0;
   while(x<pPeriodo)
   {
      i = (x + pIndiceBarra); 

      sumy+=price[i];
      sumxy+=price[i]*i;
      sumx+=i;
      sumx2+=i*i;
   
      x++;
   }

   c=sumx2*pPeriodo-sumx*sumx;
   
   if(c==0.0)
   {
      Print("Erro no calculo da regressão linear!");
      return;
   }

   b=(sumxy*pPeriodo-sumx*sumy)/c;
   a=(sumy-sumx*b)/pPeriodo;

   x = 0;
   while(x<pPeriodo)
   {
      i = (x + pIndiceBarra); 
      
      if(x==0)
         pVlrDir = a+b*i;
      else if(x==(pPeriodo-1))
         pVlrEsq = a+b*i;      
     
      x++;
   }

}




