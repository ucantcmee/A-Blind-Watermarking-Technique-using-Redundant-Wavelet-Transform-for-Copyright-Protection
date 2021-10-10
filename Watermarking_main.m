//for educational puropse only 
// For any queries contact sonusantho@gmail.com

clc;
clear all;
close all;
I=imread('b.jpg');
wm=imread('w.jpg');
I=rgb2gray(I);
wm=im2bw(wm);
imshow(I),title('host image');
figure,imshow(wm),title('watermark image');
key=5;
[ out ] = arnold( wm, key )
watermark=[out]
figure,imshow(watermark);
[r c]=size(I);
bs=8;
nob=(r/bs)*(c/bs);
% Dividing the image into 8x8 Blocks
count=[0:1:511];
total=sum(count);
x={};
kk=0;
for i=1:(r/bs)
for j=1:(c/bs)
Block(:,:,kk+j)=I((bs*(i-1)+1:bs*(i-1)+bs),(bs*(j-1)+1:bs*(j-1)+bs));
p(i)=count(i)/total;
Ehvs=-sum(p(i)*exp(1-p(i))+p(i)*log(p(i)))/2;
disp(Ehvs);
end
kk=kk+(r/bs);
end
w=1;wmrk=watermark;i=0;j=0;
for k=1:1:1024
    [LL,LH,HL,HH]=swt2(Block(:,:,k),1,'haar');
    [U S V]=svd(LL);
    a=abs(U(3,1));
    b=abs(U(4,1));
    m=(a+b)/2
    T=0.055;
    if U(3,1)>0 && U(4,1)>0
        x=1;
        alpha=T;
    end
    if U(3,1)<0 && U(4,1)<0
        x=-1;
        alpha=-T;
    end
    if wmrk(w)==0
        U(3,1)=x*m-alpha/2
        U(4,1)=x*m+alpha/2
    elseif wmrk(w)==1
        U(3,1)=x*m+alpha/2
        U(4,1)=x*m-alpha/2
    end
    w=w+1;
    LL=U*S*V';
    Block(:,:,k)=iswt2(LL,LH,HL,HH,'haar');
end
i=[]; j=[]; data=[]; count=0;
embimg1={}; % Changing complete row cell of 4096 into 64 row cell 
for j=1:64:4096
    count=count+1;
    for i=j:(j+63)
        data=[data,Block(:,:,i)];
    end
    embimg1{count}=data;
    data=[];
end
% Change 64 row cell in to particular columns to form image
i=[]; j=[]; data=[]; 
embimg=[];  % final watermark image 
for i=1:64
    embimg=[embimg;embimg1{i}];
end
% embimg=uint8(embimg);
figure,imshow(embimg);title('watermarked image');
imwrite(embimg,'watermarked.jpg');

% % % % % watermark extraction
[r c]=size(embimg);
bs=8;
nob=(r/bs)*(c/bs);
count=[0:1:511];
total=sum(count);
x={};
kk=0;
for i=1:(r/bs)
for j=1:(c/bs)
Block(:,:,kk+j)=embimg((bs*(i-1)+1:bs*(i-1)+bs),(bs*(j-1)+1:bs*(j-1)+bs));
p(i)=count(i)/total;
Ehvs=-sum(p(i)*exp(1-p(i))+p(i)*log(p(i)))/2;
% disp(Ehvs);
end
kk=kk+(r/bs);
end
for k=1:1:1024
    [LL,LH,HL,HH]=swt2(Block(:,:,k),1,'haar');
    [U S V]=svd(LL)
    for i=1:32
        if abs(U(3,1))-abs(U(4,1))>0
            wmrk(i)=1;
        else
            wmrk(i)=0;
        end    
    end
end
figure,imshow(wmrk);title('encrypted image');
key=5;
[ out ]=iarnold(wmrk,key);
figure,imshow(out);title('extracted watermark');
PSNR_WD=psnr(embimg,I);
disp('PSNR of Watermarked image');
disp(PSNR_WD);
PSNR_EW=psnr(out,double(wm))
SSIM=ssim(embimg,I);
disp('SSIM of Watermarked image');
disp(SSIM);
% NCC=normxcorr2(uint8(wm),uint8(out));
% disp('NCC of Extracted Watermark image');
% disp(NCC);
% nc1=mean(NCC(:))
% nc=normcor(uint8(wm),uint8(out))
% % plot(NCC);
% BER=biterr(out,wm);
% disp('BER of Extracted Watermark image');
% disp(BER);
% NK = NormalizedCrossCorrelation(wm,out)
M=32;
N=32;
for x=1:M
    for y=1:N
        a=sum(sum(wm(x,y)*(out(x,y))'));
        b=sqrt(sum(sum((wm(x,y))^2))*sqrt(sum(sum(((out(x,y))')^2))));
    end
end
NCC=a/b