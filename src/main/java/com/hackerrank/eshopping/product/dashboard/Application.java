package com.hackerrank.eshopping.product.dashboard;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication
@ComponentScan(basePackages = "com.hackerrank.eshopping")
public class Application
{
    public static void main (String[] args)
    {
        SpringApplication.run (Application.class, args);
    }
}
