
#二項分布での確率をもとめる
choose(100,20) * (20/100)^20 * (80/100)^80
dbinom(20,100,0.2)

#回数を1~100までセット
x=seq(0,100,1)
#二項分布をグラフにプロットする
plot(dbinom(x,100,0.2),type="h",col="blue",xlab="女性の通る回数",ylab="確率")


#確率を変えながらプロットする
z=seq(0,1,0.01)
plot(z,dbinom(20,100,z),type="h",col="blue",xlab="θ",ylab="尤度")

#確率密度関数と尤度関数の合計
sum(dbinom(x,100,0.2))
sum(dbinom(20,100,z))

#ベータ分布
z=seq(0,1,0.01)
plot(z,dbeta(z,20,100),type="h",col="blue",xlab="θ",ylab="確率密度")
sum(dbeta(z,20,100))

#事後分布
z=seq(0,1,0.01)
＃尤度関数
plot(z,dbinom(x,100,0.2)*100,type="l",col="green", ann=F, xlim=c(0, 1), ylim=c(0, 15))
par(new=T)
#事前分布
plot(z,dbeta(z,20,100),type="l",col="blue", ann=F,xlim=c(0, 1), ylim=c(0, 15))
par(new=T)
#事後分布
plot(z,dbeta(z,40,160),type="h",col="red",xlab="θ",ylab="確率密度",xlim=c(0, 1), ylim=c(0, 15))


#モンテカルロ法
#1万個の乱数を発生させる
N=10000
x = runif(N, min=-1, max=1)
y = runif(N, min=-1, max=1)

sqrt(x^2+y^2)

#x軸y軸ともに-1〜+1の範囲をプロット
plot(x, y, pch = ifelse(sqrt(x^2+y^2)<1, 20, 1))

#Π/4をもとめる
result = data.frame(table(sqrt(x^2+y^2)>1))

#4倍してΠを求める
result$Freq[1] / sum(result$Freq) * 4

#マルコフ連鎖
#初期確率の定義
Ini=matrix(c(0.5,0.5),1,2,byrow=TRUE)
#推移確率の定義
Trans=matrix(c(0.4,0.6,0.7,0.3),2,2,byrow=TRUE)

#1日後の確率
(Trans1 = Ini%*%Trans)
#2日後の確率
(Trans2 = Trans1%*%Trans)

#simplemarcov
#initial:初期確率　translate:推移確率 size:試行回数を入力して確率を計算
simplemarcov = function(initial,translate,size){
	res1 = initial[1,1]
	res2 = initial[1,2]
	for (i in 1:size)
	{
	 Tn = Tn%*%translate
 	 res1[i+1] = Tn[1,1]
 	 res2[i+1] = Tn[1,2]
	}	
	return(data.frame(res1,res2))
}

#初期確率を定義
initial=matrix(c(0.4,0.6),1,2,byrow=TRUE)
#推移確率を定義
translate=matrix(c(0.4,0.6,0.7,0.3),2,2,byrow=TRUE)

#初期確率、推移確率をもとに３０回試行
Tn=matrix(c(0.5,0.5),1,2,byrow=TRUE)
result=simplemarcov(initial,translate,30)

#結果をプロットする
plot(result$res1,col="blue",type="l",ylab="確率",xlab="回数",ylim=c(0,1.0))
par(new=TRUE)
plot(result$res2,col="red",type="l",ylab="確率",xlab="回数",ylim=c(0,1.0))

#初期確率を変える
initial=matrix(c(0.1,0.9),1,2,byrow=TRUE)
result=simplemarcov(initial,translate,30)
#結果をプロットする
plot(result$res1,col="blue",type="l",ylab="確率",xlab="回数",ylim=c(0,1.0))
par(new=TRUE)
plot(result$res2,col="red",type="l",ylab="確率",xlab="回数",ylim=c(0,1.0))




#Stan
#Rtoolsがインストールできたかを確認する
system('g++ -v')
#RStanパッケージのインストール
install.packages('rstan')
library(rstan)


#ステップ1：stanのコードを読み込む
weight='
data {
  int N;
  real X[N];
  real Y[N];
}

parameters {
  real a;
  real b;
  real<lower=0> sigma;
}

model {
  for (n in 1:N) {
    Y[n] ~ normal(a + b*X[n], sigma);
  }
}
'

#ステップ２：Rでデータをロードする
d = read.csv("https://raw.githubusercontent.com/futurebridge/RBooks/master/chap8/weight.csv") 
data = list(N=nrow(d),X=d$X, Y=d$Y) #X,Yをdataに代入


#ステップ３：StanでMCMCの実行
fit = stan(model_code=weight,data=data,iter=1000,chains=4) #stanに処理を渡す

#ステップ４：結果の値を表示
print(fit)

#ggmcmcライブラリのインストール
install.packages('ggmcmc')
library(ggmcmc)
ggmcmc(ggs(fit))

