package com.visualpathit.account.service;

import com.visualpathit.account.model.User;
import com.visualpathit.account.model.Role;
import com.visualpathit.account.repository.RoleRepository;
import com.visualpathit.account.repository.UserRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Collections;

/** {@author imrant}!*/
@Service
public class UserServiceImpl implements UserService {
    @Autowired
    /** userRepository !*/
    private UserRepository userRepository;
    @Autowired
    /** roleRepository !*/
    private RoleRepository roleRepository;
    @Autowired
    /** bCryptPasswordEncoder !*/
    private BCryptPasswordEncoder bCryptPasswordEncoder;

    @Override
    public void save(final User user) {
        Role userRole = roleRepository.findByName("ROLE_USER");

        if (userRole == null) {
            throw new IllegalStateException("ROLE_USER not found in database");
        }

        user.setPassword(bCryptPasswordEncoder.encode(user.getPassword()));
        user.setRoles(Collections.singleton(userRole));

        userRepository.save(user);
    }

    @Override
    public void update(final User user) {
        userRepository.save(user);
    }

    @Override
    public User findByUsername(final String username) {
        return userRepository.findByUsername(username);
    }
    
    @Override
    public List<User> getList() {
    	return userRepository.findAll();
    }
    @Override
	public User findById(long id){
    	return userRepository.findById(id);
    }
}
