/*
 * Name: RandomStringUtil
 * Description: generate random values. 
*/ 
public with sharing class RandomStringUtil {
    
    // Created a random string combining a random number + random string. 
    public static String generateRandomString(String inputValue) {
        Integer randomNumber = generateRandomInteger();
        String pseudoName = inputValue + randomNumber;
        Blob targetBlob = Blob.valueOf(pseudoName);
        Blob randomBytes = Crypto.generateDigest('MD5', targetBlob);
        return randomNumber + '_' + EncodingUtil.base64Encode(randomBytes);
    }

    // Provide a random integer number. 
    private static Integer generateRandomInteger() {
        return Crypto.getRandomInteger();
    }
}