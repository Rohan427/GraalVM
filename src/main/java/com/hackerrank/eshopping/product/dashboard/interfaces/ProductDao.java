/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.hackerrank.eshopping.product.dashboard.interfaces;

import com.hackerrank.eshopping.product.dashboard.model.ProductModel;
import java.util.List;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;

/**
 *
 * @author Paul G. Allen <pgallen@gmail.com>
 */
public interface ProductDao extends CrudRepository<ProductModel, Long>
{
    @Query ("SELECT p FROM Product p WHERE category = ?1 ORDER BY availability desc, discounted_price asc, id asc")
    List<ProductModel> findByCategory (String category);

    @Query ("SELECT p FROM Product p WHERE category = ?1 AND availability = ?2 ORDER BY discount_percent desc, discounted_price asc, id asc")
    List<ProductModel> findByCategoryAndAvailability (String category, boolean availability);
}
