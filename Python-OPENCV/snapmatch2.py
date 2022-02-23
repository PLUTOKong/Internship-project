import cv2 as cv
import numpy as np
import math


target = cv.imread("target.jpg")
mw = target.shape[0]
mh = target.shape[1]
tmp = cv.imread("r1.jpg",0)
w, h = tmp.shape[:2]
tmp2 = cv.imread("r2.jpg",0)
w2, h2 = tmp2.shape[:2]
limit_x = 25
limit_y = 50
offset_x = 0

def match(img,temp):
    gray_tar = cv.cvtColor(target,cv.COLOR_BGR2GRAY)
    res = cv.matchTemplate(gray_tar,temp,cv.TM_CCOEFF_NORMED)
    loc = np.where(res >=0.9)
    min_val, max_val, min_loc, max_loc = cv.minMaxLoc(res)
    score = max_val*100.0
    x= max_loc[0]
    y = max_loc[1]
    return score,x,y

def calc_angle(x1, y1, x2, y2):
    x = abs(x1 - x2)
    y = abs(y1 - y2)
    z = math.sqrt(x * x + y * y)
    angle = round(math.asin(y / z) / math.pi * 180)
    return angle

def calc_slope(x1,y1,x2,y2):
    slope = (y1-y2)/(x1-x2)
    return slope

def GetCrossAngle(x1,y1,x2,y2):
    arr_0 = np.array([((x1+(w*0.5)) - (x1+(w*0.5))), ((y1+(h/2))  -  (y2+(w2*0.5)))])
    arr_1 = np.array([((x1+(w*0.5)) - (x2+(h2*0.5))), ((y1+(h/2))  -  (y2+(w2*0.5)))])
    cos_value = (float(arr_0.dot(arr_1)) / (np.sqrt(arr_0.dot(arr_0)) * np.sqrt(arr_1.dot(arr_1)))) 
    print(arr_0)  
    return round(np.arccos(cos_value) * (180/np.pi),2)

def drawrect(img):
        sc1,x1,y1 =match(target,tmp)    
        sc2,x2,y2 =match(target,tmp2)
        # angle = calc_angle(x1, y1, x2, y2)
     
        slope = calc_slope(x1,y1,x2,y2)
        angle = GetCrossAngle(x1,y1,x2,y2)
        text = str(angle)
        text2 = str(x1+(w/2) - (x2+(h2*0.5)))
        cv.rectangle(img,(x1,y1),(x1+w,y1+h),(0,0,255),2)					
        cv.circle(img,(int(x1+(w*0.5)),int(y1+(w*0.5))),2,(0,0,255),-1)		
        cv.rectangle(img,(x2,y2),(x2+h2,y2+w2),(0,0,255),2)					
        cv.circle(img,(int(x2+(h2*0.5)),int(y2+(w2*0.5))),2,(0,0,255),-1)
        print(slope)	
        cv.line(target,(int(x1+w/2),0),(int(x1+w/2),int(mh)),(0,255,0),2)
        print(angle,"degree")
        cv.putText(target, text, (int(x1+w/2),int(y1+20)), cv.FONT_HERSHEY_SIMPLEX, 1, (255, 0, 0), 4)   
        cv.line(target,(int(x1+w/2),int(y2+(w2*0.5))),(int(x2+h2/2),int(y2+(w2*0.5))),(0,255,0),2)
        cv.putText(target, text2, (int(x2+(h2/2)+10),int(y2+(w2*0.5))), cv.FONT_HERSHEY_SIMPLEX, 1, (255, 0, 0), 4)   

def CheckPosition(img) :
        sc1,x1,y1 =match(target,tmp)    
        sc2,x2,y2 =match(target,tmp2)    
        if sc1 > 90 :
            px1 = x1+(w*0.5)
            py1 = y1+(h*0.5)
            print("Find target 1 postion:",px1,py1)    
            if sc2 > 90 :
                px2 = x2+(h2*0.5)
                py2 = y2+(w2*0.5)
                print("Find target 2 postion:",px2,py2) 
                return True,(px1,py1),(px2,py2)    
            else:
                print("cant find target 2, score :",sc2)
                return False,(0,0),(0,0)
        else:    
            print("cant find target 1, score :",sc1)
            return False,(0,0),(0,0)


ret,pt1,pt2 = CheckPosition(target)
if ret: 
    drawrect(target)              
    print(pt1)
    print(pt2)                
    color = (0,255,0)
    chk = True  
    px1 = pt1[0] + offset_x
    # py1 = pt1[1] + offset_y         
    if abs(px1 - pt2[0]) > limit_x:
        color = (0,0,255)
        msg = 'X over limit: ' + str(px1 - pt2[0]) 
        print(msg)                   
        chk = False
                
    # if abs(py1 - pt2[1]) > limit_y:
    #     color = (0,0,255)
    #     msg = ' Y over limit: ' + str(py1 - pt2[1])
    #     print(msg)  
    #     chk = False

    if chk:
        msg = "PASS"
        text = str(px1 - pt2[0])    
        print(msg)    
        cv.line(target,(int(pt1[0]),int(pt1[1])),(int(pt2[0]),int(pt2[1])),color,2)
        
else:
    msg = 'ERROR'
    cv.putText(target, msg, (500,100), cv.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 2)
    
cv.namedWindow('result',cv.WINDOW_GUI_NORMAL)
cv.imshow('result', target)
cv.imwrite('report.jpg',target)
cv.waitKey(0)