import cv2 as cv
import numpy as np
import math

target = cv.imread("target.jpg")
tmp = cv.imread("r1.jpg",0)
w, h = tmp.shape[:2]
tmp2 = cv.imread("r2.jpg",0)
w2, h2 = tmp2.shape[:2]
limit_x = 25
limit_y = 50
   
def match(img,temp):
    gray_tar = cv.cvtColor(target,cv.COLOR_BGR2GRAY)
    res = cv.matchTemplate(gray_tar,tmp,cv.TM_CCOEFF_NORMED)
    loc = np.where(res >=0.9)
    min_val, max_val, min_loc, max_loc = cv.minMaxLoc(res)
    score = max_val*100.0
    x= max_loc[0]
    y = max_loc[1]
    res2 = cv.matchTemplate(gray_tar,tmp2,cv.TM_CCOEFF_NORMED)
    loc2 = np.where(res2 >=0.9)
    min_val2, max_val2, min_loc2, max_loc2 = cv.minMaxLoc(res2)
    score2 = max_val2*100.0
    x2 = max_loc2[0]
    y2 = max_loc2[1]

    # area1 = [(x,y),(x+w,y+h)]
    # area2 = [(x2,y2),(x2+h2,y2+w2)]

    # ROI1 = target[y:y+h,x:x+w]
    # ROI2 = target[y2:y2+w2,x2:x2+h2]

    if score > 90 and score2 > 90:
        print(score,x,y)
        cv.rectangle(img,max_loc,(x+w,y+h),(0,0,255),2)					
        cv.circle(img,(int(x+(w*0.5)),int(y+(w*0.5))),2,(0,0,255),-1)		
        print("Find target 1 postion:",x+(w*0.5),y+(h*0.5))    

        print(score2,x2,y2)
        cv.rectangle(img,max_loc2,(x2+h2,y2+w2),(0,0,255),2)					
        cv.circle(img,(int(x2+(h2*0.5)),int(y2+(w2*0.5))),2,(0,0,255),-1)		
        print("Find target 2 postion:",x2+(w2*0.5),y2+(h2*0.5))    
        cv.line(img,(int(x+(w*0.5)),int(y+(h*0.5))),(int(x2+(h2*0.5)),int(y2+(w2*0.5))),(0,0,255),2)      
        return score,score2,x,y,x2,y2
    
    else:
        print("not find")
def drawrect():
    s


def CheckPosition(img) :
    x,y  



    # img1=target[y:y+h,x:x+w]
    # img2=target[y2:y2+h2,x2:x2+w2]
    



cv.namedWindow('result',cv.WINDOW_GUI_NORMAL)
match(target,tmp,tmp2)
cv.imshow('result', target)
cv.waitKey(0)