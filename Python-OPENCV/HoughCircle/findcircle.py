import cv2 as cv
import numpy as np
 
img = cv.imread("target.jpg")
img1=img[2062:2137,1610:1685]
gay_img =cv.cvtColor(img1,cv.COLOR_BGRA2GRAY)
imgblur  = cv.medianBlur(gay_img, 7)  #进行中值模糊，去噪点
cimg = cv.cvtColor(imgblur, cv.COLOR_GRAY2BGR)

circles = cv.HoughCircles(imgblur,cv.HOUGH_GRADIENT, 1, 200, param1=50, param2=30, minRadius=0, maxRadius=0)
 
circles = np.uint16(np.around(circles))
print(circles)
 
 
for i in circles[0,:]: #遍历矩阵每一行的数据
    cv.circle(img1, (i[0],i[1]),i[2],(0,255,0) ,2)
    cv.circle(img1, (i[0], i[1]),2, (0,0,255) ,3)         
 
 
cv.imshow("gay_img", img1)
cv.waitKey(0)
cv.destroyAllWindows()