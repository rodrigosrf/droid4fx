//+------------------------------------------------------------------+
//|                                    Droid4FX-LinearRegression.mq4 |
//|                                     Copyright © 2013, Rodrigo S. |
//+------------------------------------------------------------------+

//Propriedades
#property copyright "Copyright © 2014, Rodrigo S."
#property link      "rodrigosf@outlook.com"
#property description "Droid4FX Regrassão Linear"
#property strict

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1  Black
#property indicator_color2  Blue
#property indicator_color3  Blue
// Buffers
double buffer[];
double bufferUp[];
double bufferDown[];
// Variavel Externa
extern int  Periodo     = 21;
extern int  TipoPreco   = 0;
extern int  Ordem       = 3;
extern int  Desvio      = 1;
extern bool Bandas      = true;

int OnInit(void)
{
   class CFix { } ExtFix;   

   IndicatorShortName("Droid4FX-Polinomial");

   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID);
   SetIndexBuffer(0, buffer);
   SetIndexDrawBegin(0, Periodo);

   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID);
   SetIndexBuffer(1, bufferUp);
   SetIndexDrawBegin(1, Periodo);

   SetIndexStyle(2, DRAW_LINE, STYLE_SOLID);
   SetIndexBuffer(2, bufferDown);
   SetIndexDrawBegin(2, Periodo);

   return(INIT_SUCCEEDED);
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{

   int i, limit;
   double valorFinal = 0;
   double lista[];
   double desvio = 0;

   if(rates_total<=Periodo || Periodo<=0) return(0);

   ArraySetAsSeries(buffer,false);
   ArraySetAsSeries(bufferUp,false);
   ArraySetAsSeries(bufferDown,false);      
   ArraySetAsSeries(close,false);
   ArraySetAsSeries(high,false);
   ArraySetAsSeries(low,false);      
     
   if(prev_calculated<1)
   {
      for(i=0; i<Periodo; i++)
      {
         buffer[i]=EMPTY_VALUE;
         bufferUp[i]=EMPTY_VALUE;
         bufferDown[i]=EMPTY_VALUE;                  
      }   
   }

   if(TipoPreco==0)
   {
      ArrayCopy(lista, close);
   }   
   else if(TipoPreco==1)
   {
      ArrayCopy(lista, low);
   }
   else if(TipoPreco==2)
   {
      ArrayCopy(lista, high);
   }

   limit = Periodo - 1;
   if(prev_calculated>Periodo) limit = prev_calculated-1;   

   for(i=limit; i<rates_total && !IsStopped(); i++)
   {
      RegressaoPolinomial(Ordem, i, lista, buffer[i]);
      if(Bandas)
      {
         desvio = DesvioPadrao(i, buffer);
         bufferUp[i]   = buffer[i] + (desvio * Desvio);
         bufferDown[i] = buffer[i] - (desvio * Desvio);
      }   
   }   
     
   return(rates_total);
   
}

void RegressaoPolinomial(int ordem, int position, const double &price[], double &valorFinal)
{

   double matrizX[];
   double matrizY[]; 
   int x = 0;
   
   ArrayResize(matrizX, Periodo);
   ArrayResize(matrizY, Periodo);
     
   ArrayInitialize(matrizX, 0);
   ArrayInitialize(matrizY, 0);      

   while(x<Periodo)
   {
      matrizX[x] = x + 1;   
      matrizY[x] = price[position-x];
      x++;
   }
  
   FindPolynomialLeastSquaresFit(matrizX, matrizY, Ordem, Periodo, Periodo, valorFinal);
   
}

double DesvioPadrao(int position, const double &price[]) 
{
   int x = 0;
   double media = 0;
   double variancia = 0;   
   double desvio = 0;
   
   while(x<Periodo)
   {
      media += price[position-x];
      x++;
   }
   media = (media / Periodo);

   x = 0;
   while(x<Periodo)
   {
      variancia += MathPow((price[position-x] - media), 2);
      x++;
   }
   variancia = (variancia / Periodo);
   desvio = MathSqrt(variancia);
   
   return (desvio);

}

void FindPolynomialLeastSquaresFit(
                                   const double& arX[], 
                                   const double& arY[], 
                                   const int ordem,
                                   const int periodo,                                   
                                   const int posicao,
                                   double& resultado)
{

   double coeffs[10][10];
   double answer[];
   double total = 0;
   double x_factor = 0;   

   int pt = 0;

   ArrayInitialize(coeffs, 0);
   
   for(int j=0;j<=ordem;j++)
   {
      coeffs[j][ordem + 1] = 0;
   
      for(pt=0;pt<periodo;pt++)
      {
         coeffs[j][ordem + 1] = coeffs[j][ordem + 1] - MathPow(arX[pt], j) * arY[pt];
      }
      
      for(int a_sub=0;a_sub<=ordem;a_sub++)
      {
         coeffs[j][a_sub] = 0;      
         for(pt=0;pt<periodo;pt++)
         {
            coeffs[j][a_sub] = coeffs[j][a_sub] - MathPow(arX[pt], a_sub + j); 
         }
      }      
   }
   
   GaussianElimination(coeffs, answer, Ordem, Ordem + 1); 

   x_factor = 1;

   for(int i=0;i<ArraySize(answer);i++)
   {
      total = total + x_factor * answer[i];
      x_factor = x_factor * 1;
   } 

   total = NormalizeDouble(total, 5);
   resultado = total;
   
}                                    

void GaussianElimination(
                         double& coeffs[10][10], 
                         double& answer[],
                         int max_equation, 
                         int max_coeff)
{

   int i = 0;
   int j = 0;
   int k = 0;
   int d = 0;   
   double temp = 0;
   double coeff_i_i = 0;
   double coef_j_i = 0;
   
   for(i=0;i<=max_equation;i++)
   {
      if(coeffs[i][i]==0)
      {
         for(j=0;j<=max_equation;j++)
         {
            if(coeffs[j][i]!=0)
            {
               for(k=i;k<=max_coeff;k++)
               {
                  temp = coeffs[i][k];
                  coeffs[i][k] = coeffs[j][k];
                  coeffs[j][k] = temp;
               }               
               break;
            }
         }
      }
      
      coeff_i_i = coeffs[i][i];
      if(coeff_i_i==0) return;
      
      for(j=i;j<=max_coeff;j++)
      {
         coeffs[i][j] = coeffs[i][j] / coeff_i_i;
      }
      
      for(j=0;j<=max_equation;j++)
      {
         if(j!=i)
         {
            coef_j_i = coeffs[j][i];
            for(d=0;d<=max_coeff;d++)
            {
               coeffs[j][d] = coeffs[j][d] - coeffs[i][d] * coef_j_i;
            }         
         }
      }
   
   }
   
   ArrayResize(answer, max_equation + 1);
   ArrayInitialize(answer, 0);
      
   for(i=0;i<=max_equation;i++)
   {
      answer[i] = coeffs[i][max_coeff];
   }

}

void OnDeinit(const int reason)
{
   Comment("");
}
