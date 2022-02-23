import cv2 as cv
import numpy as np
import math

cap = cv.VideoCapture("http://192.168.60.233:8080/?action=stream") 
tmp = cv.imread("cap.jpg")
w, h = tmp.shape[:2]
tmp2 = cv.imread("candy2.jpg")
w2, h2 = tmp2.shape[:2]

def match(img,tmp,tmp2):
    gray_img = cv.cvtColor(img,cv.COLOR_BGR2GRAY)
    res = cv.matchTemplate(img,tmp,cv.TM_CCOEFF_NORMED)
    loc = np.where(res >=0.7)
    min_val, max_val, min_loc, max_loc = cv.minMaxLoc(res)
    score = max_val*100.0
    x = max_loc[0]
    y = max_loc[1]
    res2 = cv.matchTemplate(img,tmp2,cv.TM_CCOEFF_NORMED)
    loc2 = np.where(res2 >=0.5)
    min_val2, max_val2, min_loc2, max_loc2 = cv.minMaxLoc(res2)
    score2 = max_val2*100.0
    x2 = max_loc2[0]
    y2 = max_loc2[1]
  
    if score > 70 and score2 > 50:
        print(score,x,y)
        cv.rectangle(img,max_loc,(x+w,y+h),(0,255,0),1)					
        cv.circle(img,(int(x+(w*0.5)),int(y+(w*0.5))),2,(0,0,255),-1)		
        print("Find target 1 postion:",x+(w*0.5),y+(h*0.5))    

        print(score2,x2,y2)
        cv.rectangle(img,max_loc2,(x2+h2,y2+w2),(0,255,0),1)					
        cv.circle(img,(int(x2+(h2*0.5)),int(y2+(w2*0.5))),2,(0,0,255),-1)		
        print("Find target 2 postion:",x2+(w2*0.5),y2+(h2*0.5))    
        cv.line(img,(int(x+(w*0.5)),int(y+(h*0.5))),(int(x2+(h2*0.5)),int(y2+(w2*0.5))),(0,0,255),2)         
    check_position(x,w,y,h,x2,w2,y2,h2)

def check_position(x,w,y,h,x2,w2,y2,h2):       
    p1 = np.array([int(x+(w*0.5)),int(y+(h*0.5))])
    p2 = np.array([int(x2+(w2*0.5)),int(y2+(h2*0.5))])
    p3 = p2 - p1
    p4 = math.hypot(p3[0],p3[1])
    print("Distance of 2 object is: ",p4)   

while(True):
    ret,frame = cap.read()
    cv.imshow("capture",frame)
    key_input = cv.waitKey(1) & 0xFF
    if key_input == ord('q'):
        break

    elif key_input == ord('z'):
        print("check match")
        iap = cv.VideoCapture("http://192.168.60.233:8080/?action=snapshot") 
        ret,img = iap.read()
        match(img,tmp,tmp2)
        cv.imshow('result', img)
        cv.imwrite("C:/Users/lingyu/Desktop/prd_red/result.jpg", img)

cap.release()
cv.destroyAllWindows()