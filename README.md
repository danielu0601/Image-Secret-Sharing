# Image-Secret-Sharing

This is an implementation of Progressive Image Secret Sharing.

## Introduction

This work use Shamir's Secret Sharing and DCT Transform to achieve Progressive Image Secret Sharing.

## Usage

1. All test images are put in 'img'.
2. 'Demo' is an demo that can use webcam to capture image and simulate the result shared with our approach.
3. In 'src', there are several version of secret sharing.
   The execute methods are using corresponding 'run.m', the example parameters are also in 'run.m':
   1. **Secret Sharing without Progressive**  
     Corresponding files: "run.m", Encrypt.m", and "Decrypt.m".  
     This will do only simple secret sharing without progressive.  
   2. **Secret Sharing with Progressive**  
     Corresponding files: "run_progressive.m", "Encrypt_Progressive.m" and "Decrypt_Progressive.m".  
     This is the progressive method proposed by [Kuo-Hsien Hung and Dr. Ja-Chen Lin](http://140.113.39.130/cdrfb3/record/nctu/#NT910394026)  
   3. **Smaller Progressive Secret Sharing**  
     Corresponding files: Use "run_progressive_2.m", "Encrypt_Progressive_2.m" and "Decrypt_Progressive_2.m".  
     The difference between this and previous one is that this one do the rearrange before sharing, while previous one share by a block, so the secret size can be smaller.  
   4. **Progressive Secret Sharing with Deidentification**  
     Corresponding files: Use "run_p_d.m", "Encrypt_P_D.m" and "Decrypt_P_D.m".  
     This one will share the image into N shares, and with K or more shares can progressively recover the image except that the sensitive area will only recover with all shares.  
   5. **Faster version of 4**  
     I tried to use some techiques to speed up the process.  But because I used MATLAB, there is a limit of speedup.
   6. **Audio Secret Sharing**
     Failed attempting for doing audio secret sharing.
4. Some part of 1~3 had broken because I changed 'Equation.m', 'Solve_Eq.m' when implementing 5.
5. The files in 'srcC' are C verion that are under construction.